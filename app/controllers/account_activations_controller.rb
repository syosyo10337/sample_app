class AccountActivationsController < ApplicationController
  
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      
      #users#create(->signup)の時にsession[:id]入れずに、メールを送るようにしたので、メールのリンクを踏むときににログインさせてあげる
      log_in user
      flash[:success] = "Your account activated!"
      redirect_to user
    else
      #もし何かの手違いで、条件が満たされない時(不正なアクセス等)
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

end
