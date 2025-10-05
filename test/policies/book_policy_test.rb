require 'test_helper'

class BookPolicyTest < ActiveSupport::TestCase
  def setup
    @book = books(:one)
    @librarian = users(:librarian)
    @student = users(:student)
    @admin = users(:admin)
  end

  test 'librarian can create update destroy' do
    policy = BookPolicy.new(@librarian, @book)
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test 'student cannot modify' do
    policy = BookPolicy.new(@student, @book)
    refute policy.create?
    refute policy.update?
    refute policy.destroy?
  end

  test 'admin cannot modify (only librarian)' do
    policy = BookPolicy.new(@admin, @book)
    refute policy.create?
    refute policy.update?
    refute policy.destroy?
  end
end
