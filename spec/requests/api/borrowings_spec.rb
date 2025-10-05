require 'rails_helper'

RSpec.describe 'API::Borrowings', type: :request do
  let!(:user) { User.create!(name: 'User', email: 'u@example.com', password: 'password', role: 'student') }
  let!(:book) { Book.create!(title: 'Book', author: 'Auth', isbn: '111', total_copies: 2, available_copies: 2) }

  def auth_header
    post '/api/login', params: { email: user.email, password: 'password' }
    token = JSON.parse(response.body)['token']
    { 'Authorization' => "Bearer #{token}" }
  end

  it 'creates and lists borrowings' do
    post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header
    expect(response).to have_http_status(:created)

    get '/api/borrowings', headers: auth_header
    expect(response).to have_http_status(:ok)
    list = JSON.parse(response.body)
    expect(list.is_a?(Array)).to be true
  end
end
