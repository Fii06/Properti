require "test_helper"

class PriceEstimatorServiceTest < ActiveSupport::TestCase
  test "uses area baseline when njop override is blank" do
    properti = build_property(njop: nil)

    result = PriceEstimatorService.new(properti, riwayat_hargas: history_data).estimate

    assert_equal 4_800_000, result[:baseline_njop]
    assert_operator result[:min], :<=, result[:mid]
    assert_operator result[:mid], :<=, result[:max]
  end

  test "uses manual njop override when provided" do
    properti = build_property(njop: 6_200_000)

    result = PriceEstimatorService.new(properti, riwayat_hargas: history_data).estimate

    assert_equal 6_200_000, result[:baseline_njop]
  end

  test "historical prices influence recommendation" do
    properti = build_property(njop: nil)

    no_history = PriceEstimatorService.new(properti, riwayat_hargas: []).estimate
    with_history = PriceEstimatorService.new(properti, riwayat_hargas: history_data).estimate

    assert_operator with_history[:mid], :>, no_history[:mid]
  end

  private

  def build_property(njop:)
    Propertis.new(
      alamat: "Jl. Raya Bojongsoang No. 10",
      daerah: "Bojongsoang",
      kecamatan: "Bojongsoang",
      kelurahan: "Bojongsoang",
      latitude: -6.9901,
      longitude: 107.6295,
      luas_tanah: 120,
      luas_bangunan: 90,
      tahun_pembangunan: 2018,
      status_kepemilikan: "SHM",
      njop: njop,
      images: Array.new(5, "img")
    )
  end

  def history_data
    [
      { tanggal: "2024-01-10", harga: 820_000_000 },
      { tanggal: "2025-01-10", harga: 860_000_000 },
      { tanggal: "2026-01-10", harga: 900_000_000 }
    ]
  end
end
