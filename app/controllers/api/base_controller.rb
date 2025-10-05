module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :ensure_json

    private

    def ensure_json
      request.format = :json
    end
  end
end
