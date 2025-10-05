require 'rails_helper'

RSpec.describe 'Borrowings API', type: :request do
  let(:student) { create(:user) }
  let(:librarian) { create(:user, :librarian) }
  let(:book) { create(:book) }

  describe 'POST /api/borrowings' do
    it 'creates borrowing for student' do
      post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
      expect(response).to have_http_status(:created)
    end
    it 'prevents duplicate active borrowing' do
      post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
      post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'forbids librarian' do
      post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(librarian)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/borrowings/:id/return_book' do
    it 'marks borrowing returned' do
      post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
      borrowing_id = JSON.parse(response.body)['id']
      post "/api/borrowings/#{borrowing_id}/return_book", headers: auth_header(student)
      expect(response).to have_http_status(:ok)
      expect(Borrowing.find(borrowing_id).status).to eq 'returned'
    end
  end

  describe 'GET /api/borrowings/overdue' do
    it 'lists overdue for librarian' do
      create(:borrowing, :overdue, user: student, book: book)
      get '/api/borrowings/overdue', headers: auth_header(librarian)
      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      ids = parsed.is_a?(Array) ? parsed.map { |h| h['id'] } : parsed['data'].map { |d| d['id'] }
      expect(ids).not_to be_empty
    end
  end
end
