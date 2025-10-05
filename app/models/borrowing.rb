class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  STATUSES = %w[borrowed returned overdue].freeze

  validates :status, inclusion: { in: STATUSES }
  validate :book_must_be_available, on: :create
  validate :no_duplicate_active_borrowing, on: :create

  before_validation :set_initial_fields, on: :create
  after_create :decrement_book
  after_update :increment_book_if_returned

  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where('due_at < ?', Time.current) }

  def mark_returned!
    transaction do
      update!(returned_at: Time.current, status: 'returned')
    end
  end

  def mark_overdue!
    update!(status: 'overdue') if status == 'borrowed'
  end

  def borrow_duration_days
    return 0 unless borrowed_at
    ((Time.current - borrowed_at) / 1.day).floor
  end

  def days_remaining
    return 0 unless due_at
    return 0 if returned_at.present?
    rem = ((due_at - Time.current) / 1.day).ceil
    rem.negative? ? 0 : rem
  end

  private

  def set_initial_fields
    self.borrowed_at ||= Time.current
    self.due_at ||= 14.days.from_now
    self.status ||= 'borrowed'
  end

  def book_must_be_available
    errors.add(:book, 'is not available') unless book&.available?
  end

  def decrement_book
    book.borrow_one!
  end

  def increment_book_if_returned
    if saved_change_to_returned_at? && returned_at.present?
      book.return_one!
    end
  end

  def no_duplicate_active_borrowing
    if Borrowing.where(user_id: user_id, book_id: book_id, returned_at: nil).exists?
      errors.add(:base, 'You already have this book borrowed')
    end
  end
end
