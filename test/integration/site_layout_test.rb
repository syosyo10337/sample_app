require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:michael)
  end

  #ログイン後と、ログイン前で場合分けしてテスト書いた方が良いかも。
  test "layout links before login and after" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    #未ログインの時
    assert_select "a[href=?]", login_path
    log_in_as(@user)
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    #ログイン済みの時
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    #演習の問題なのでコメントアウト
    # get contact_path
    # assert_select "title", full_title("Contact")
    # get signup_path
    # assert_select "title", full_title("Sign up")
    assert_select "div.stats"
  end

end
