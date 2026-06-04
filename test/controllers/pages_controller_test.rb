require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home renders with shared layout" do
    get root_path

    assert_response :success
    assert_includes response.body, "Temukan Harga Properti yang Adil &amp; Masuk Akal"
    assert_includes response.body, "data-theme-toggle"
    assert_includes response.body, "© #{Time.current.year} SPK Properti"
  end

  test "listings filters by location keyword across address hierarchy" do
    Propertis.create!(
      alamat: "Jl. Raya Bojongsoang No. 10",
      daerah: "Baleendah",
      kecamatan: "Bojongsoang",
      kelurahan: "Bojongsoang",
      latitude: -6.9901,
      longitude: 107.6295,
      luas_tanah: 120,
      luas_bangunan: 90,
      tahun_pembangunan: 2018,
      status_kepemilikan: "SHM",
      njop: 2_500_000,
      harga_pasar: 910_000_000,
      images: Array.new(5) { "data:image/jpeg;base64,ZmFrZQ==" }
    )

    get listings_path(q: "Bojongsoang")

    assert_response :success
    assert_includes response.body, "Jl. Raya Bojongsoang No. 10"
  end

  test "neighborhoods renders Bojongsoang facilities from backend" do
    get neighborhoods_path

    assert_response :success
    assert_includes response.body, "Filter kategori fasilitas"
    assert_includes response.body, "Telkom University"
    assert_includes response.body, "Borma Bojongsoang"
    assert_includes response.body, "Lihat listing sekitar Bojongsoang"
  end

  test "neighborhoods filters facilities by category" do
    get neighborhoods_path(category: "pendidikan")

    assert_response :success
    assert_includes response.body, "Telkom University"
    refute_includes response.body, "Masjid Besar Bojongsoang"
  end
end
