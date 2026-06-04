require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
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
