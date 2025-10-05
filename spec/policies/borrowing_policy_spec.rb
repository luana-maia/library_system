require 'rails_helper'

RSpec.describe BorrowingPolicy do
  subject(:policy) { described_class }

  let(:student) { create(:user) }
  let(:librarian) { create(:user, :librarian) }
  let(:admin) { create(:user, :admin) }
  let(:borrowing) { create(:borrowing, user: student) }

  it 'allows student create' do
    expect(policy.new(student, Borrowing.new(book: create(:book), user: student)).create?).to be true
  end

  it 'denies librarian create' do
    expect(policy.new(librarian, Borrowing.new(book: create(:book), user: librarian)).create?).to be false
  end

  it 'scope returns all for librarian' do
    expect(Pundit.policy_scope(librarian, Borrowing)).to include(borrowing)
  end

  it 'scope returns only own for student' do
  borrowing # ensure student's borrowing exists
  create(:borrowing, user: create(:user))
    expect(Pundit.policy_scope(student, Borrowing).pluck(:user_id).uniq).to eq([student.id])
  end

  it 'return_book? allowed for owner and librarian' do
    expect(policy.new(student, borrowing).return_book?).to be true
    expect(policy.new(librarian, borrowing).return_book?).to be true
  end
end
