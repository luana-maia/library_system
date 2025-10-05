require 'test_helper'

class BorrowingPolicyTest < ActiveSupport::TestCase
  def setup
    @student = users(:student)
    @librarian = users(:librarian)
    @admin = users(:admin)
    @borrowing = Borrowing.create!(book: books(:one), user: @student)
  end

  test 'student create allowed' do
    assert BorrowingPolicy.new(@student, Borrowing.new(book: books(:one), user: @student)).create?
  end

  test 'librarian create denied' do
    refute BorrowingPolicy.new(@librarian, Borrowing.new(book: books(:one), user: @librarian)).create?
  end

  test 'scope returns all for librarian' do
    ids = Pundit.policy_scope(@librarian, Borrowing).pluck(:id)
    assert_includes ids, @borrowing.id
  end

  test 'scope returns only own for student' do
    student2 = User.create!(name: 'Other', email: 'other@example.com', role: 'student', password: 'password')
    Borrowing.create!(book: books(:two), user: student2)
    ids = Pundit.policy_scope(@student, Borrowing).pluck(:user_id).uniq
    assert_equal [@student.id], ids
  end

  test 'return_book? allowed for owner and librarian' do
    assert BorrowingPolicy.new(@student, @borrowing).return_book?
    assert BorrowingPolicy.new(@librarian, @borrowing).return_book?
  end
end
