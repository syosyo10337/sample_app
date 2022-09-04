require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
 
  
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user) 
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: {
      name: @user.name,
      email: @user.email #ユーザ情報を編集するのを再現。パスがないのはvalidationかかってないから、名前と
      }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin atrribute to be edit via web" do
    log_in_as(@other_user)  
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: {
      papassword:              "password",
      password_confirmation: "password",
      admin: true } }
    assert_not @other_user.reload.admin?
  end
  #ログインしてない状態で、deleteを何らかの方法で使用としたとき。
  test "should redirect destroy when not logged in" do
    #DELETEリクエストの前後で、ユーザ数変化なし(＝削除されていない)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    #loginを促すページへredirect
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when logged in as  a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end



end
