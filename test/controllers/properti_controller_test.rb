require "test_helper"
require "tempfile"
require "rack/test"

class PropertisControllerTest < ActionDispatch::IntegrationTest
  test "should get services without route conflict" do
    get services_path

    assert_response :success
    assert_includes response.body, "Jual Properti dengan Rekomendasi Harga SPK"
    assert_includes response.body, ">NOP<"
  end

  test "preview shows recommendations and explanation for valid property input" do
    post preview_property_path, params: {
      propertis: valid_property_params(images: uploaded_images)
    }

    assert_response :success
    assert_includes response.body, "Pilih Harga Jual"
    assert_includes response.body, "Ringkasan Estimasi"
    assert_includes response.body, "NJOP manual tersimpan"
    refute_includes response.body, "Harga Tanah"
    refute_includes response.body, "Harga Bangunan"

    referensi = ReferensiNjop.last
    assert_not_nil referensi
    assert_equal "32.73.101.100.001.0001.0", referensi.nomor_njop
    assert_equal 5_500_000, referensi.harga_per_m2.to_i
    assert_equal "Jl. Raya Bojongsoang No. 10", referensi.alamat
  end

  test "preview rejects incomplete history and too few images" do
    params = valid_property_params(
      images: uploaded_images(count: 2),
      riwayat_hargas: [{ tanggal: "", harga: "" }]
    )

    post preview_property_path, params: { propertis: params }

    assert_response :unprocessable_entity
    assert_includes response.body, "minimal 5 gambar"
    assert_includes response.body, "isi minimal satu riwayat harga properti"
  end

  test "preview rejects incomplete njop reference and does not persist it" do
    params = valid_property_params(images: uploaded_images)
    params[:kd_blok] = ""
    params[:harga_per_m2] = ""

    post preview_property_path, params: { propertis: params }

    assert_response :unprocessable_entity
    assert_includes response.body, "Kode blok NJOP harus diisi"
    assert_includes response.body, "Harga NJOP per m2 harus diisi"
    assert_equal 0, ReferensiNjop.count
  end

  test "create persists property history and analysis" do
    post preview_property_path, params: {
      propertis: valid_property_params(images: uploaded_images)
    }

    assert_response :success

    preview_token = response.body[/name="preview_token" value="([^"]+)"/, 1]
    assert preview_token.present?, "expected preview token to be present in the publish form"

    post create_property_path, params: {
      preview_token: preview_token,
      propertis: valid_property_params(images: []),
      harga_final: "910000000"
    }

    assert_redirected_to listings_path
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Harga: Rp "
    assert_includes response.body, "data:image/"

    properti = Propertis.last
    assert_not_nil properti
    assert_equal "Jl. Raya Bojongsoang No. 10", properti.alamat
    assert_equal 3, properti.riwayat_hargas.count
    assert_equal 1, properti.analisis_hargas.count
    assert_equal 910_000_000, properti.harga_pasar.to_i
    assert_equal 5_500_000, properti.njop.to_i
    assert_equal "heuristic_fallback", properti.analisis_hargas.first.metode
    assert_equal "32.73.101.100.001.0001.0", properti.analisis_hargas.first.input_snapshot["nomor_njop"]
  end

  test "preview updates existing referensi njop for the same number" do
    post preview_property_path, params: {
      propertis: valid_property_params(images: uploaded_images)
    }

    updated_params = valid_property_params(images: uploaded_images)
    updated_params[:alamat] = "Jl. Raya Bojongsoang No. 99"
    updated_params[:harga_per_m2] = "6100000"

    post preview_property_path, params: {
      propertis: updated_params
    }

    assert_response :success
    assert_equal 1, ReferensiNjop.count
    referensi = ReferensiNjop.first
    assert_equal 6_100_000, referensi.harga_per_m2.to_i
    assert_equal "Jl. Raya Bojongsoang No. 99", referensi.alamat
  end

  test "preview accepts jpg uploads with non standard mime type" do
    post preview_property_path, params: {
      propertis: valid_property_params(images: uploaded_images(content_type: "image/jpg"))
    }

    assert_response :success
    assert_includes response.body, "data:image/jpeg;base64,"
  end

  test "show renders map on detail page when coordinates are available" do
    properti = create_property_record(latitude: -6.9901, longitude: 107.6295)

    get listing_path(properti)

    assert_response :success
    assert_includes response.body, "Lokasi Properti"
    assert_includes response.body, 'id="listing-detail-map"'
    assert_includes response.body, 'data-latitude="-6.9901"'
    assert_includes response.body, 'data-longitude="107.6295"'
  end

  test "show renders fallback when coordinates are missing" do
    properti = create_property_record(latitude: nil, longitude: nil, validate: false)

    get listing_path(properti)

    assert_response :success
    assert_includes response.body, "Lokasi belum tersedia"
    refute_includes response.body, 'id="listing-detail-map"'
  end

  private

  def valid_property_params(images:)
    {
      alamat: "Jl. Raya Bojongsoang No. 10",
      daerah: "Bojongsoang",
      kecamatan: "Bojongsoang",
      kelurahan: "Bojongsoang",
      latitude: "-6.9901",
      longitude: "107.6295",
      luas_tanah: "120",
      luas_bangunan: "90",
      tahun_pembangunan: "2018",
      status_kepemilikan: "SHM",
      njop: "",
      kd_propinsi: "32",
      kd_dati2: "73",
      kd_kecamatan: "101",
      kd_kelurahan: "100",
      kd_blok: "001",
      no_urut: "0001",
      kd_jns_op: "0",
      harga_per_m2: "5500000",
      images: images,
      riwayat_hargas: [
        { tanggal: "2024-01-10", harga: "820000000" },
        { tanggal: "2025-01-10", harga: "860000000" },
        { tanggal: "2026-01-10", harga: "900000000" }
      ]
    }
  end

  def uploaded_images(count: 5, content_type: "image/jpeg")
    Array.new(count) do |index|
      file = Tempfile.new(["property-#{index}", ".jpg"])
      file.binmode
      file.write("fake-image-#{index}")
      file.rewind
      Rack::Test::UploadedFile.new(file.path, content_type, true)
    end
  end

  def encoded_images(count: 5)
    Array.new(count) { |index| Base64.strict_encode64("fake-image-#{index}") }
  end

  def create_property_record(latitude:, longitude:, validate: true)
    attributes = {
      alamat: "Jl. Raya Bojongsoang No. 10",
      daerah: "Bojongsoang",
      kecamatan: "Bojongsoang",
      kelurahan: "Bojongsoang",
      latitude: latitude,
      longitude: longitude,
      luas_tanah: 120,
      luas_bangunan: 90,
      tahun_pembangunan: 2018,
      status_kepemilikan: "SHM",
      njop: 2_500_000,
      harga_pasar: 910_000_000,
      harga_rekomendasi_min: 860_000_000,
      harga_rekomendasi_mid: 910_000_000,
      harga_rekomendasi_max: 960_000_000,
      images: Array.new(5) { "data:image/jpeg;base64,ZmFrZQ==" }
    }

    properti = Propertis.new(attributes)
    validate ? properti.tap(&:save!) : properti.tap { |record| record.save!(validate: false) }
  end
end
