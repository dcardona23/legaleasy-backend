class JwtService
  def self.encode(payload)
    secret_key = Rails.application.secret_key_base
    JWT.encode(payload, secret_key)
  end
end
