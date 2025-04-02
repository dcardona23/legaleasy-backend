class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix

  def create
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      token = user.generate_jwt
      render json: {
        status: {
          code: 200,
          message: "Logged in successfully.",
          data: {
            user: UserSerializer.new(user).serializable_hash[:data][:attributes],
            token: token
          }
        }
      }, status: :ok
    else
        render json: {
          status: { message: "Invalid email or password" }
        }, status: :unauthorized
    end
  end

  def destroy
    if request.headers["Authorization"].present?
      token = request.headers["Authorization"].split(" ").last

      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key).first
        user_id = decoded_token["sub"]

        current_user = User.find_by(id: user_id)

        if current_user
          render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      rescue JWT::DecodeError => e
        render json: {
          status: 400,
          message: "Invalid or expired token.",
          error: e.message
        }, status: :bad_request
      end
    else
      render json: {
        status: 400,
        message: "Authorization token missing."
      }, status: :bad_request
    end
  end

  private

  def respond_to_on_destroy
  end
end
