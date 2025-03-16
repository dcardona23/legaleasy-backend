class Api::V1::OpenaiController < ApplicationController
  before_action :authenticate_user!
  def create
    render json: {}, status: :ok
  end
end
