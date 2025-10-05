require 'rails_helper'

RSpec.describe BookPolicy do
  subject(:policy) { described_class }

  let(:book) { build(:book) }
  let(:librarian) { build(:user, :librarian) }
  let(:student) { build(:user) }
  let(:admin) { build(:user, :admin) }

  it 'allows librarian to mutate' do
    expect(policy.new(librarian, book).create?).to be true
    expect(policy.new(librarian, book).update?).to be true
    expect(policy.new(librarian, book).destroy?).to be true
  end

  it 'denies student mutations' do
    p = policy.new(student, book)
    expect(p.create?).to be false
    expect(p.update?).to be false
    expect(p.destroy?).to be false
  end

  it 'denies admin mutations (only librarian)' do
    p = policy.new(admin, book)
    expect(p.create?).to be false
  end
end
