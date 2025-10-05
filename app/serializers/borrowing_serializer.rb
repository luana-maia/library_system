class BorrowingSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :book_id, :borrowed_at, :due_at, :returned_at, :status,
             :borrow_duration_days, :days_remaining
  belongs_to :user
  belongs_to :book
end
