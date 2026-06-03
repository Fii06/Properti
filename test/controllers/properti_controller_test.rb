require "test_helper"
require "tempfile"
require "rack/test"

class PropertisControllerTest < ActionDispatch::IntegrationTest
  test "should get services without route conflict" do
    get services_path

    assert_response :success
    assert_includes response.body, "Jual Properti dengan Rekomendasi Harga SPK"
  end

  test "preview shows recommendations and explanation for valid property input" do
    post preview_property_path, params: {
      propertis: valid_property_params(images: uploaded_images)
    }

    assert_response :success
    assert_includes response.body, "Pilih Harga Jual"
    assert_includes response.body, "Ringkasan Estimasi"
    assert_includes response.body, "Baseline NJOP"
    refute_includes response.body, "Harga Tanah"
    refute_includes response.body, "Harga Bangunan"
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
    assert_equal "heuristic_fallback", properti.analisis_hargas.first.metode
  end

  test "preview accepts jpg uploads with non standard mime type" do
    post preview_property_path, params: {
      propertis: valid_property_params(images: uploaded_images(content_type: "image/jpg"))
    }

    assert_response :success
    assert_includes response.body, "data:image/jpeg;base64,"
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
end
