require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match user.activation_token, mail.body.encoded
    
    #assert_matchと、CGIクラスのescapeメソッドを使うことで、@を文字コード(%40)で表現
    assert_match CGI.escape(user.email), mail.body.encoded
  end

  
  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    #mail変数に、メールの送信内容をassign
    mail = UserMailer.password_reset(user)

    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    #tokenが埋め込まれているかを確認
    assert_match user.reset_token, mail.body.encoded
    #emailが埋め込まれているかを確認
    assert_match CGI.escape(user.email), mail.body.encoded
  end

end
