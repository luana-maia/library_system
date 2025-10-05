require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test 'syncs available copies on create when nil' do
    b = Book.create!(title: 'T', author: 'A', isbn: 'X1', total_copies: 3)
    assert_equal 3, b.available_copies
  end

  test 'borrow_one! decrements when available' do
    book = books(:one)
    assert_difference -> { book.reload.available_copies }, -1 do
      book.borrow_one!
    end
  end

  test 'borrow_one! raises when no copies' do
    book = Book.create!(title: 'Empty', author: 'Z', isbn: 'E1', total_copies: 0, available_copies: 0)
    assert_raises(StandardError) { book.borrow_one! }
  end

  test 'search matches title author and genre and blank returns all' do
    assert_includes Book.search('clean').map(&:id), books(:one).id
    assert_includes Book.search('martin').map(&:id), books(:one).id
    assert_includes Book.search('programming').map(&:id), books(:one).id
    all_ids = Book.search(nil).pluck(:id)
    assert_equal Book.count, all_ids.size
  end
end
