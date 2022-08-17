require 'test_helper'
require_relative '../controllers/static_pages_controller_test'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, 'Ruby on Rails Tutorial Sample App'      
    assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Sample App"
  end
end