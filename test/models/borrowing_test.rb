require 'test_helper'

class BorrowingTest < ActiveSupport::TestCase
  test 'creating borrowing decrements book available copies' do
    book = books(:one)
    student = users(:student)
    assert_difference -> { book.reload.available_copies }, -1 do
      Borrowing.create!(book: book, user: student)
    end
  end

  test 'cannot create duplicate active borrowing' do
    book = books(:one)
    student = users(:student)
    Borrowing.create!(book: book, user: student)
    dup = Borrowing.new(book: book, user: student)
    assert_not dup.valid?
    assert_includes dup.errors.full_messages.join, 'already have'
  end

  test 'mark_returned! updates status and increments copies' do
    book = books(:one)
    student = users(:student)
    borrowing = Borrowing.create!(book: book, user: student)
    assert_difference -> { book.reload.available_copies }, +1 do
      borrowing.mark_returned!
    end
    assert_equal 'returned', borrowing.reload.status
    assert borrowing.returned_at.present?
  end

  test 'overdue scope finds overdue active borrowings' do
    over = borrowings(:overdue_borrowing)
    assert_includes Borrowing.overdue.map(&:id), over.id
  end
end
