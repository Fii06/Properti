require "test_helper"

class PropertiControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get properti_index_url
    assert_response :success
  end

  test "should get show" do
    get properti_show_url
    assert_response :success
  end

  test "should get new" do
    get properti_new_url
    assert_response :success
  end

  test "should get create" do
    get properti_create_url
    assert_response :success
  end

  test "should get edit" do
    get properti_edit_url
    assert_response :success
  end

  test "should get update" do
    get properti_update_url
    assert_response :success
  end

  test "should get destroy" do
    get properti_destroy_url
    assert_response :success
  end
end
