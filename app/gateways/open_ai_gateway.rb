class OpenAIGateway
  def self.conn
      conn = Faraday.new(url: "https://api.openai.com/v1/chat/completions") do |faraday|
          faraday.headers["Authorization"]= "Bearer #{Rails.application.credentials.dig(:open_ai_api, :key)}"
          faraday.headers["Content-Type"] = "application/json"
      end
  end
end
