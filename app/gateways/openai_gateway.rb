class OpenaiGateway
  def self.conn
      conn = Faraday.new(url: "https://api.openai.com") do |faraday|
          faraday.headers["Authorization"]= "Bearer #{Rails.application.credentials.dig(:open_ai_api, :key)}"
          faraday.headers["Content-Type"] = "application/json"
      end
  end

  def self.request(conversation_history)
    response = conn.post("/v1/chat/completions") do |req|
      req.body = {
        "model": "gpt-4o-mini",
        "messages": conversation_history
      }.to_json
    end
    response.body
  end
end
