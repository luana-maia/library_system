require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  let(:student) { create(:user) }
  let(:book) { create(:book, available_copies: 3, total_copies: 3) }

  it 'decrements book availability on create' do
    expect { create(:borrowing, user: student, book: book) }.to change { book.reload.available_copies }.by(-1)
  end

  it 'prevents duplicate active borrowing' do
    create(:borrowing, user: student, book: book)
    dup = Borrowing.new(user: student, book: book)
    expect(dup).not_to be_valid
    expect(dup.errors.full_messages.join).to match(/already have/i)
  end

  it 'mark_returned! sets status returned and increments copies' do
    borrowing = create(:borrowing, user: student, book: book)
    expect { borrowing.mark_returned! }.to change { book.reload.available_copies }.by(1)
    expect(borrowing.reload.status).to eq 'returned'
    expect(borrowing.returned_at).to be_present
  end

  it 'overdue scope returns overdue borrowings' do
    over = create(:borrowing, :overdue, user: student, book: book)
    expect(Borrowing.overdue).to include(over)
  end
end
