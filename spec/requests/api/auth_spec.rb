require 'rails_helper'

RSpec.describe 'API::Auth', type: :request do
  describe 'POST /api/login' do
    let!(:user) { User.create!(name: 'Tester', email: 'tester@example.com', password: 'password', role: 'student') }

    it 'returns token for valid credentials' do
      post '/api/login', params: { email: 'tester@example.com', password: 'password' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present
    end

    it 'rejects invalid credentials' do
      post '/api/login', params: { email: 'tester@example.com', password: 'wrong' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
