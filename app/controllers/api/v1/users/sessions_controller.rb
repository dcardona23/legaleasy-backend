class Api::V1::Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [ :create ]

  # POST /resource/sign_in
  def create
    @user = User.find_by(email: params[:user][:email])

    if @user && @user.valid_password?(params[:user][:password])
      token = JwtService.encode(user_id: @user.id)
      render json: { message: "Session started successfully", token: token, user: @user }, status: :created
    else
        render json: { errors: [ "Invalid email or password" ] }, status: :unprocessable_entity
    end
  end

  # DELETE /resource/sign_out
  def destroy
    head :no_content
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :email, :password ])
  end
end
