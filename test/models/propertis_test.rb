require "test_helper"

class PropertisTest < ActiveSupport::TestCase
  test "status kepemilikan must match form options" do
    properti = build_property(status_kepemilikan: "INVALID")

    assert_not properti.valid?
    assert_includes properti.errors[:status_kepemilikan], "is not included in the list"
  end

  test "listing scopes handle keyword and max price filters" do
    matching = build_property(alamat: "Jl. Raya Bojongsoang No. 10", harga_pasar: 900_000_000)
    matching.save!

    other = build_property(
      alamat: "Jl. Buahbatu No. 5",
      daerah: "Bandung",
      kecamatan: "Lengkong",
      kelurahan: "Turangga",
      harga_pasar: 1_500_000_000
    )
    other.save!

    filtered = Propertis.matching_query("Bojongsoang").within_price(1_000_000_000)

    assert_includes filtered, matching
    assert_not_includes filtered, other
  end

  private

  def build_property(attributes = {})
    Propertis.new(
      {
        alamat: "Jl. Default No. 1",
        daerah: "Bojongsoang",
        kecamatan: "Bojongsoang",
        kelurahan: "Bojongsoang",
        latitude: -6.9901,
        longitude: 107.6295,
        luas_tanah: 120,
        luas_bangunan: 90,
        tahun_pembangunan: 2018,
        status_kepemilikan: "SHM",
        njop: 2_500_000,
        harga_pasar: 950_000_000,
        images: Array.new(5) { "data:image/jpeg;base64,ZmFrZQ==" }
      }.merge(attributes)
    )
  end
end
