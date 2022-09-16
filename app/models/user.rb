class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy                                
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


  #DBでは扱わない仮想的な属性をユーザオブジェクトに付与し、アクセスできるような状態する。
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :email_downcase
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true



  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end
  #仮想的な属性に値を代入し、それをハッシュ化したダイジェストをデータベースに保存
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  #渡されたトークンがダイジェストを一致するか判定する。(true/false)
  #has_secure_passwordを参考した。
  #remember_digestはself.が省略されている
  def authenticated?(attribute, token)
    # self.send("#{attribute}_digest")のselfは省略してもデータ属性を参照できるよね！
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  #ユーザのログイン情報を破棄する。
  def forget
    update_attribute(:remember_digest, nil)
  end


  #アカウントを有効化する(refactor)
  def activate
    #user.update_attributeのuserが省略されている(モデル内にuserという変数は定義されていない)
    #self.update_attributeと書くこともできる。
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  #有効化用のメールを送信する。(refactor)
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #パスワード再設定用の属性をset
  def create_reset_digest
    #トークン生成のメソッドをまたもや流用
    self.reset_token = User.new_token
    #仮想じゃないので、Railsの流儀に乗っ取って
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  #パスワード再設定メールを送信
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    #2時間以上経っている時trueを返す。
    #2hours.ago => 現在時刻の2H前と、再設定が送信された時間を比較し、後者が古い場合はtrue
    reset_sent_at < 2.hours.ago
  end

  #proto-feedのためのメソッド定義
  def feed
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id:  id)
    #self.id -> id 
  end


  #ユーザをフォローする
  def follow(other_user)
    following << other_user
    #self.followingの省略。フォローをしている対象群の配列に追加
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end


  def following?(other_user)
    following.include?(other_user)
  end


  private
    def email_downcase
      #self.email = self.email.downcase と書いても実装できる
      #self.email = email.downcase #selfが両辺に存在する時は省略可能
      self.email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
      #アサインする形なのでselfは省略できないです。
    end
   
    

    
end
