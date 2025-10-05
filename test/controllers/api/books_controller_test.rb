require 'test_helper'

class Api::BooksControllerTest < ActionDispatch::IntegrationTest
  def auth_header(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  test 'index returns books' do
    get '/api/books'
    assert_response :success
    body = JSON.parse(response.body)
    assert body.is_a?(Array) || body['data']
  end

  test 'librarian can create book' do
    payload = { book: { title: 'New', author: 'Auth', isbn: 'NEW-ISBN', total_copies: 1, available_copies: 1 } }
    post '/api/books', params: payload, headers: auth_header(users(:librarian))
    assert_response :created
  end

  test 'student cannot create book' do
    payload = { book: { title: 'New2', author: 'Auth', isbn: 'NEW-ISBN2', total_copies: 1, available_copies: 1 } }
    post '/api/books', params: payload, headers: auth_header(users(:student))
    assert_response :forbidden
  end

  test 'update book librarian only' do
    patch "/api/books/#{books(:one).id}", params: { book: { title: 'Updated' } }, headers: auth_header(users(:librarian))
    assert_response :success
    assert_equal 'Updated', books(:one).reload.title
  end

  test 'destroy book librarian only' do
    assert_difference 'Book.count', -1 do
      delete "/api/books/#{books(:two).id}", headers: auth_header(users(:librarian))
    end
    assert_response :no_content
  end
end
