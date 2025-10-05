module Api
  class UsersController < BaseController
    def index
      users = policy_scope(User).order(created_at: :desc).page(params[:page])
      render json: users, each_serializer: UserSerializer
    end

    def show
      user = User.find(params[:id])
      authorize user
      render json: user
    end

    def create
      user = User.new(user_params)
      authorize user
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      user = User.find(params[:id])
      authorize user
      if user.update(user_params)
        render json: user
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find(params[:id])
      authorize user
      user.destroy
      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
    end
  end
end
