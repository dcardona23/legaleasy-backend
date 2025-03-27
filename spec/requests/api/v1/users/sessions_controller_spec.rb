require "rails_helper"

RSpec.describe Api::V1::Users::SessionsController, type: :request do
  describe "POST /api/v1/users/sign_in" do
    let(:user) { FactoryBot.create(:user) }

    context "with valid credentials" do
      it "returns 201: Created" do
        post api_v1_user_session_path, params: { user: { email: user.email, password: user.password } }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq("Session started successfully")
      end
    end

    context "with invalid credentials" do
      it "returns 422: Unprocessable Entity" do
        post api_v1_user_session_path, params: { user: { email: user.email, password: "wrong_password" } }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Invalid email or password")
      end
    end
  end
end
