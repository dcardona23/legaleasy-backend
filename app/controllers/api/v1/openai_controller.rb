require_dependency "open_ai_gateway"

class Api::V1::OpenaiController < ApplicationController
  def create
    user_input = params[:formInput]
    json = OpenAiGateway.request(user_input)
    render json: response, status: :ok
  end
end
