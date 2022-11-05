class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in? # sessionshelperでっせ。
      store_location
      flash[:danger] = "Please log in"
      redirect_to login_url # '/login'へ
    end
  end
end
