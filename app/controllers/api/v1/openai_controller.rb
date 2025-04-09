require_dependency "openai_gateway"

class Api::V1::OpenaiController < ApplicationController
  before_action :authenticate_user_from_token!

  def create
    user_input = params[:formInput]

    conversation = @current_user.conversations.last || Conversation.create(user: @current_user, history: [])
    conversation_history = JSON.parse(conversation.history || "[]")
    conversation_history <<
      { role: "system", content: "You are a licensed attorney in Colorado, and your job is to identify the correct forms for a client to complete to accomplish the task or tasks they identify. If you require more information to provide a thorough response to the client's request with all forms that are applicable to their situation, you must ask follow-up questions. Your response to the client must provide clickable links that list the names and form numbers of the forms the client should complete. Please format clickable links using markdown, and if you mention any resources, ensure the URL is formatted like this: [link text](url). The clickable links should take the client to the form's location on the Colorado Judicial Branch website - https://www.coloradojudicial.gov/self-help-forms. The client has provided the following information about their situation: #{user_input}."
    }

    ai_response = OpenaiGateway.request(conversation_history)

    ai_message = JSON.parse(ai_response)["choices"].first["message"]["content"]
    conversation_history << { role: "assistant", content: ai_message }

    conversation.update(history: conversation_history.to_json)

    render json: { response: ai_message }, status: :ok
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
