module AuthHelpers
  def auth_header(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |c|
  c.include AuthHelpers, type: :request
end
