class ApplicationController < ActionController::API
  respond_to :json
  before_action :process_token

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end

  def current_user
    @current_user ||= super || User.find(@current_user_id)
    Rails.logger.info("Current user ID: #{@current_user_id}")
  end


  def signed_in?
    @current_user_id.present?
  end
  
  def process_token
    if request.headers["Authorization"].present?
      token = request.headers["Authorization"].split(" ")[1].remove('"')
      Rails.logger.debug("JWT Token: #{token}")

      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key).first
        Rails.logger.debug("Decoded JWT Payload: #{jwt_payload}")
        @current_user_id = jwt_payload["id"]
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
        Rails.logger.error("JWT Error: #{e.message}")
        head :unauthorized
      end
    else
      Rails.logger.warn("Authorization header missing")
    end
  end
end
