require "test_helper"

class ReferensiNjopTest < ActiveSupport::TestCase
  test "builds canonical nomor njop from segments" do
    nomor = ReferensiNjop.build_nomor_njop(
      kd_propinsi: "32",
      kd_dati2: "73",
      kd_kecamatan: "101",
      kd_kelurahan: "100",
      kd_blok: "001",
      no_urut: "0001",
      kd_jns_op: "0"
    )

    assert_equal "32.73.101.100.001.0001.0", nomor
  end

  test "upsert_from_input updates existing record for the same nomor njop" do
    ReferensiNjop.upsert_from_input!(
      kd_propinsi: "32",
      kd_dati2: "73",
      kd_kecamatan: "101",
      kd_kelurahan: "100",
      kd_blok: "001",
      no_urut: "0001",
      kd_jns_op: "0",
      harga_per_m2: "5500000",
      alamat: "Alamat pertama"
    )

    ReferensiNjop.upsert_from_input!(
      kd_propinsi: "32",
      kd_dati2: "73",
      kd_kecamatan: "101",
      kd_kelurahan: "100",
      kd_blok: "001",
      no_urut: "0001",
      kd_jns_op: "0",
      harga_per_m2: "6100000",
      alamat: "Alamat kedua"
    )

    assert_equal 1, ReferensiNjop.count
    referensi = ReferensiNjop.first
    assert_equal 6_100_000, referensi.harga_per_m2.to_i
    assert_equal "Alamat kedua", referensi.alamat
  end
end
