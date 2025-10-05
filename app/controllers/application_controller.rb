class ApplicationController < ActionController::Base
	include Pundit::Authorization

	protect_from_forgery with: :null_session

	before_action :set_current_user

	rescue_from Pundit::NotAuthorizedError do |e|
		render json: { error: 'Not authorized' }, status: :forbidden
	end

	private

		def set_current_user
			auth_header = request.headers['Authorization']
			if auth_header&.start_with?('Bearer ')
				token = auth_header.split(' ').last
				decoded = JsonWebToken.decode(token)
				@current_user = User.find_by(id: decoded[:user_id]) if decoded
			end
		end

	def current_user
		@current_user
	end
end
