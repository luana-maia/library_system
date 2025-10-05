require 'rails_helper'

RSpec.describe 'Books API', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:student) { create(:user) }

  describe 'GET /api/books' do
    it 'lists books' do
      create_list(:book, 2)
      get '/api/books'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/books' do
    let(:params) { { book: { title: 'New', author: 'Auth', isbn: 'XYZ-1', total_copies: 1, available_copies: 1 } } }
    it 'allows librarian' do
      post '/api/books', params: params, headers: auth_header(librarian)
      expect(response).to have_http_status(:created)
    end
    it 'forbids student' do
      post '/api/books', params: params, headers: auth_header(student)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PATCH /api/books/:id' do
    it 'updates book with librarian' do
      book = create(:book)
      patch "/api/books/#{book.id}", params: { book: { title: 'Updated' } }, headers: auth_header(librarian)
      expect(response).to have_http_status(:ok)
      expect(book.reload.title).to eq 'Updated'
    end
  end

  describe 'DELETE /api/books/:id' do
    it 'destroys with librarian' do
      book = create(:book)
      delete "/api/books/#{book.id}", headers: auth_header(librarian)
      expect(response).to have_http_status(:no_content)
      expect(Book.exists?(book.id)).to be false
    end
  end
end
