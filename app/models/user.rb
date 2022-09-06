class User < ApplicationRecord
  #DBでは扱わない仮想的な属性をユーザオブジェクトに付与し、アクセスできるような状態する。
  attr_accessor :remember_token, :activation_token
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
    # digest = self.send("#{attribute}_digest")のselfは省略してもデータ属性を参照できるよね！
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  #ユーザのログイン情報を破棄する。
  def forget
    update_attribute(:remember_digest, nil)
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
    end
   
end
