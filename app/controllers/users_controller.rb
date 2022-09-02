#Applitcation_controller内でsessionshelperinclude済みです。
class UsersController < ApplicationController
 before_action :logged_in_user, only: [:edit, :update]
 before_action :correct_user, only: [:edit, :update]
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user #user_url(@user.id)->show
    else
      render 'edit' #'users/new'だけどusersコントローラだから省略
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  
    #beforeアクション
    
    #ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in? #sessionshelperでっせ。
        store_location
        flash[:danger] = "Please log in"
        redirect_to login_url #'/login'へ
      end
    end
    #アクセスしたユーザページとcurrent_userを比較 
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end
