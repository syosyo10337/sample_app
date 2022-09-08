# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)

  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    #サンプルユーザを一人適当に見繕って、送信相手とする。
    user = User.first
    #メールないでのリンクに組み込まれているので必要
    user.reset_token = User.new_token
    #メール送信
    UserMailer.password_reset(user)
  end

end
