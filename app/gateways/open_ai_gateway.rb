class OpenAiGateway
  def self.conn
      conn = Faraday.new(url: "https://api.openai.com/v1") do |faraday|
          faraday.headers["Authorization"]= "Bearer #{Rails.application.credentials.dig(:open_ai_api, :key)}"
          faraday.headers["Content-Type"] = "application/json"
      end
  end

  def self.request(user_input)
    response = conn.post("/chat/completions") do |req|
      req.body = {
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a licensed attorney in Colorado, and your job is to identify the correct forms for a client to complete to accomplish the task or tasks they identify. If you require more information to provide a thorough response to the client's request with all forms that are applicable to their situation, you must ask follow-up questions. Your response to the client must list the names and form numbers of the forms the client should complete, and the names of the forms must link to the form's location on the Colorado Judicial Branch website - https://www.coloradojudicial.gov/self-help-forms."
          },
          {
            "role": "user",
            "content": user_input
          }
        ]
      }.to_json
    end
    response.body
  end
end
