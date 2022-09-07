require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  #deliveriesは配列で、テストをするごと初期化してあげることで、のちのassert_equalではメールの配信数を確認できる。
  def setup
    ActionMailer::Base.deliveries.clear
  end


  #無効な値でのSignupに対するフロー
  test "invaid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {user: { name: '',
                                        email: 'user@invalid',
                                        password: "foo",
                                        password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  #有効な値でのSignupに対するフロー(/w activation)
  test "valid signup infomation with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: {user: { name: 'Example',
                                        email: 'user@valid.com',
                                        password:              "foobar",
                                        password_confirmation: "foobar" } }
    end
    #メールが送信された.size(数)を1だと主張
    assert_equal 1, ActionMailer::Base.deliveries.size
    #コントローラで定義される@userにアクセスできるようにして
    user = assigns(:user)
    #アクセスできるようになったuserに対して
    assert_not user.activated?
    #1 有効化せずにログインに試みる
    log_in_as(user)
    assert_not is_logged_in?
    #2  有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    #3トークンは正しいがメアドがinvalidな場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    #4 activation_token/email共に正しい値の時
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.blank?
    assert is_logged_in?
  end
end
