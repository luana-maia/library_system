FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Book #{n}" }
    author { "Author" }
    sequence(:isbn) { |n| "ISBN-#{1000+n}" }
    genre { 'Programming' }
    total_copies { 3 }
    available_copies { 3 }
  end
end
