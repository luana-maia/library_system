class Book < ApplicationRecord
	has_many :borrowings, dependent: :destroy

	scope :search, ->(term) do
		return all if term.blank?
		q = "%#{sanitize_sql_like(term.downcase)}%"
		where("LOWER(title) LIKE :q OR LOWER(author) LIKE :q OR LOWER(COALESCE(genre,'')) LIKE :q", q: q)
	end

	validates :title, :author, :isbn, presence: true
	validates :isbn, uniqueness: true
	validates :total_copies, numericality: { greater_than_or_equal_to: 0 }
	validates :available_copies, numericality: { greater_than_or_equal_to: 0 }

	before_validation :sync_available_copies, on: :create

	def available?
		available_copies.to_i > 0
	end

	def borrow_one!
		raise StandardError, 'No copies available' unless available?
		decrement!(:available_copies)
	end

	def return_one!
		increment!(:available_copies) if available_copies < total_copies
	end

	private

	def sync_available_copies
		self.available_copies = total_copies if available_copies.nil?
	end
end
