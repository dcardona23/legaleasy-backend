require_dependency "openai_gateway"

class Api::V1::OpenaiController < ApplicationController
  before_action :authenticate_user_from_token!

  def create
    user_input = params[:formInput]

    ai_message = @current_user.get_conversation_history(user_input)

    formatted_response = Kramdown::Document.new(ai_message).to_html

    render json: { response: formatted_response }, status: :ok
  end

  private

  def authenticate_user_from_token!
      token = request.headers["Authorization"].to_s.split(" ").last

      if token.present?
        begin
          decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key, "HS256")
      user_id = decoded_token[0]["sub"]

      @current_user = User.find(user_id)
      @current_user
    rescue JWT::DecodeError => e
      render json: { error: "Unauthorized: Invalid token" }, status: :unauthorized
      end
      else
      render json: { error: "Unauthorized: No token provided" }, status: :unauthorized
      end
  end

  def current_user
    @current_user
  end
end
