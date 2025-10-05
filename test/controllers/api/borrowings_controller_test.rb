require 'test_helper'

class Api::BorrowingsControllerTest < ActionDispatch::IntegrationTest
  def auth_header(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  test 'student can create borrowing and duplicate prevented' do
    student = users(:student)
    book = books(:one)
    post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
    assert_response :created
    post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
    assert_response :unprocessable_entity
  end

  test 'librarian cannot create borrowing' do
    librarian = users(:librarian)
    book = books(:one)
    post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(librarian)
    assert_response :forbidden
  end

  test 'return_book marks borrowing returned' do
    student = users(:student)
  # create isolated book to avoid conflicts with existing overdue fixture
  book = Book.create!(title: 'Temp', author: 'Auth', isbn: "TMP-#{SecureRandom.hex(4)}", total_copies: 1, available_copies: 1)
  post '/api/borrowings', params: { borrowing: { book_id: book.id } }, headers: auth_header(student)
    assert_response :created
    borrowing_id = JSON.parse(response.body)['id']
    post "/api/borrowings/#{borrowing_id}/return_book", headers: auth_header(student)
    assert_response :success
    assert_equal 'returned', Borrowing.find(borrowing_id).status
  end

  test 'overdue endpoint lists overdue borrowing' do
    get '/api/borrowings/overdue', headers: auth_header(users(:librarian))
    assert_response :success
    body = JSON.parse(response.body)
    ids = body.map { |b| b['id'] } rescue body['data'].map { |d| d['id'] }
    assert_includes ids, borrowings(:overdue_borrowing).id
  end
end
