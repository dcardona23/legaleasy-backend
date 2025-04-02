require "rails_helper"

describe "User login", type: :request do
  let(:user) { FactoryBot.create(:user) }

  context "with valid credentials" do
    it "returns 201: Created" do
      post api_v1_user_session_path, params: { user: { email: user.email, password: user.password } }

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq("Logged in successfully.")
    end
  end

  context "with invalid credentials" do
    it "returns 422: Unprocessable Entity" do
      post api_v1_user_session_path, params: { user: { email: user.email, password: "wrong_password" } }

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(json_response['status']['message']).to include("Invalid email or password")
    end
  end
end
