require "test_helper"

class FasilitasTest < ActiveSupport::TestCase
  test "seed_bojongsoang_defaults creates default facilities once" do
    assert_difference("Fasilitas.count", Fasilitas::BOJONGSOANG_DEFAULTS.size) do
      Fasilitas.seed_bojongsoang_defaults!
    end

    assert_no_difference("Fasilitas.count") do
      Fasilitas.seed_bojongsoang_defaults!
    end

    fasilitas = Fasilitas.find_by(nama: "Telkom University")
    assert_equal "pendidikan", fasilitas.kategori
    assert_equal "Sukapura", fasilitas.area_kelurahan
  end

  test "requires the expected Bojongsoang facility fields" do
    fasilitas = Fasilitas.new(nama: "Fasilitas Contoh")

    assert_not fasilitas.valid?
    assert_includes fasilitas.errors[:kategori], "is not included in the list"
    assert_includes fasilitas.errors[:alamat], "can't be blank"
    assert_includes fasilitas.errors[:deskripsi_singkat], "can't be blank"
    assert_includes fasilitas.errors[:area_kelurahan], "can't be blank"
  end
end
