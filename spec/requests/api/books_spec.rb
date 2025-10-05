require 'rails_helper'

RSpec.describe 'API::Books', type: :request do
  describe 'GET /api/books' do
    it 'returns books list' do
      get '/api/books'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_a(Array)
    end
  end
end
