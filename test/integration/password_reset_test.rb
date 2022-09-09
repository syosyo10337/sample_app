require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password reset" do 
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'

    #メールアドレスが無効な場合
    post password_resets_path, params: { password_reset: { email: ""} }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    #メールアドレスが有効な場合
    post password_resets_path, params: { password_reset: { email: @user.email} }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest#reset_digestの値が更新されているか？
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    
    #パスワード再設定フォーム(edit)に関するテスト
    user = assigns(:user)
    #メールアドレスがwrong
    #この時点ではまだ、:michael
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url

    #inactiveユーザの場合
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)  #再度userをactivated

    #right email とwrong tokenをリンクから受け取った時
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    #right email & right tokenの時
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email #hiddenフィールドにuser.emailの値もっているか？

    #実際のパスワード更新(update)にまつわるテスト
    #Invalid password & confirmationの時
    patch password_reset_path(user.reset_token), params: { email: user.email,
    user: { password: 'foobaz',
            password_confirmation: 'barquux'}}
    assert_select 'div#error_explanation'
    #エラーメッセージ表示するdivタグが出る

    #passwordが空だった場合
    patch password_reset_path(user.reset_token), params: { email: user.email,
    user: { password: '',
            password_confirmation: ''}}
    assert_select 'div#error_explanation'

    #有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token), params: { email: user.email,
      user: { password: 'foobar',
              password_confirmation: 'foobar'}}
    assert_nil user.reload.reset_digest 
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  #有効期限ぎれのtokenがある時
  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: {
      email: @user.email}
    }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: {email: @user.email,
     user: { password: "foobaer",
              password_confirmation: "foobar"}}
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end

    



 
end
