module SessionsHelper
  #渡されたユーザーでログインする。
  def log_in(user)
    session[:user_id] = user.id 
  end
  #ユーザのセッションを永続的にする。
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  #現在ログインしているユーザを返す
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end
  #永続セッションを破棄する。(永続クッキーをデリート)
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  #現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  #慣習に習ってcurrent_user?というへルパーメソッドを作成
  def current_user?(user)
    user && user == current_user
    #もしuserがnilの時ただnilを返す
    #単に user == current_userでもいいんですけど
  end

  #記憶したURL(or default)にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
    #returnするか、式が最後まで評価された後に、redirectが発生するので、２行目のセッション削除は常に有効です。
  end

  #ユーザがリクエストしてたURLを記憶する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
