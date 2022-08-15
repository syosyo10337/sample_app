require 'test_helper'

class StaticPages homeControllerTest < ActionDispatch::IntegrationTest
  test "should get help" do
    get static_pages home_help_url
    assert_response :success
  end

end
