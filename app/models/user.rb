class User < ApplicationRecord
	has_secure_password

	has_many :borrowings, dependent: :destroy
	has_many :borrowed_books, through: :borrowings, source: :book

	ROLES = %w[admin librarian student].freeze

	validates :name, presence: true
	validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
	validates :role, inclusion: { in: ROLES }

	def admin?
		role == 'admin'
	end

	def librarian?
		role == 'librarian'
	end

	def student?
		role == 'student'
	end
end
