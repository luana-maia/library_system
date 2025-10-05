FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    role { 'student' }

    trait :librarian do
      role { 'librarian' }
    end

    trait :admin do
      role { 'admin' }
    end
  end
end
