# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts 'Seeding base data...'

admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
	u.name = 'Admin'
	u.role = 'admin'
	u.password = 'password'
	u.password_confirmation = 'password'
end

librarian = User.find_or_create_by!(email: 'librarian@example.com') do |u|
	u.name = 'Librarian'
	u.role = 'librarian'
	u.password = 'password'
	u.password_confirmation = 'password'
end

student = User.find_or_create_by!(email: 'student@example.com') do |u|
	u.name = 'Student'
	u.role = 'student'
	u.password = 'password'
	u.password_confirmation = 'password'
end

books = [
	{ title: 'Clean Code', author: 'Robert C. Martin', isbn: '9780132350884', total_copies: 5 },
	{ title: 'Pragmatic Programmer', author: 'Andrew Hunt', isbn: '9780201616224', total_copies: 3 },
	{ title: 'Design Patterns', author: 'Erich Gamma', isbn: '9780201633610', total_copies: 4 }
]

books.each do |attrs|
	Book.find_or_create_by!(isbn: attrs[:isbn]) do |b|
		b.title = attrs[:title]
		b.author = attrs[:author]
		b.total_copies = attrs[:total_copies]
		b.available_copies = attrs[:total_copies]
	end
end

puts 'Seed complete.'
