class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  has_many :conversations

  def generate_jwt
    jti = SecureRandom.uuid

    payload = {
      sub: self.id,
      exp: 60.days.from_now.to_i,
      jti: jti
    }

    JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key, "HS256")
  end
end
