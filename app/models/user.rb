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

  def get_conversation_history(user_input)
    conversation = self.conversations.last || Conversation.create(user: self, history: [])

    conversation_history = JSON.parse(conversation.history || "[]")
    conversation_history <<
      { role: "system", content: "You are a licensed attorney in Colorado, and your job is to identify the correct forms for a client to complete to accomplish the task or tasks they identify. If you require more information to provide a thorough response to the client's request with all forms that are applicable to their situation, you must ask follow-up questions. Please write your response at a 6th grade reading level using clear, simple language. Avoid legal jargon unless it is absolutely necessary, and if you use it, define it in plain terms. Your tone should be friendly, helpful, and reassuring. Once you have identified the forms the client should complete, your response must follow this format: Line 1 - 'To assist you with (the process identified by the client), below is a comprehensive list of the necessary forms that you will need to complete. You may find all forms on the [Colorado Judicial Branch Self Help website](https://www.coloradojudicial.gov/self-help-forms)'; Line 2 - the title and form number of the first form the client will need to complete; Line 3 - A brief description of the form identified on Line 2; Lines 4 and on should follow this same format. Your response to the client must be in markdown. The link to the Colorado Judicial Branch Self Help website should be clickable, but do not provide other links to resources or guess at URLs. I will handle linking forms in the app. The client has provided the following information about their situation: #{user_input}."
    }

    ai_response = OpenaiGateway.request(conversation_history)

    ai_message = JSON.parse(ai_response)["choices"].first["message"]["content"]
    conversation_history << { role: "assistant", content: ai_message }

    conversation.update(history: conversation_history.to_json)

    ai_message
  end
end
