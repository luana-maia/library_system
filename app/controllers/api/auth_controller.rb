module Api
  class AuthController < BaseController
    skip_before_action :ensure_json, only: :login
    skip_before_action :set_current_user, only: :login rescue nil

    def login
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token, user: UserSerializer.new(user) }
      else
        render json: { error: 'Invalid credentials' }, status: :unauthorized
      end
    end
  end
end
