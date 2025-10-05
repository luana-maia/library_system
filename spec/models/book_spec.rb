require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'callbacks' do
    it 'sets available_copies on create when nil' do
      b = Book.create!(title: 'T', author: 'A', isbn: 'X1', total_copies: 5)
      expect(b.available_copies).to eq 5
    end
  end

  describe '#borrow_one!' do
    it 'decrements available copies' do
      book = create(:book, available_copies: 2)
      expect { book.borrow_one! }.to change { book.reload.available_copies }.by(-1)
    end

    it 'raises if none available' do
      book = create(:book, total_copies: 0, available_copies: 0)
      expect { book.borrow_one! }.to raise_error(StandardError)
    end
  end

  describe '.search' do
    it 'finds by title, author, or genre and blank returns all' do
      b1 = create(:book, title: 'Clean Code', author: 'Robert Martin', genre: 'Software')
      _b2 = create(:book, title: 'Pragmatic Programmer', author: 'Andy Hunt', genre: 'Programming')
      expect(Book.search('clean')).to include(b1)
      expect(Book.search('martin')).to include(b1)
      expect(Book.search('software')).to include(b1)
      expect(Book.search(nil).count).to eq(Book.count)
    end
  end
end
