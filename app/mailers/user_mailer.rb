class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    #宛先をユーザのemailに,件名を'Account activation'に
    mail to: user.email, subject: 'Account activation'
  end
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:

  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    #mailのview(template)でユーザ名を表示したい
    mail to: user.email, subject: 'Password reset'
  end
end
