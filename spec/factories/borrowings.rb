FactoryBot.define do
  factory :borrowing do
    association :user
    association :book
    borrowed_at { Time.current }
    due_at { 14.days.from_now }
    returned_at { nil }
    status { 'borrowed' }

    trait :overdue do
      borrowed_at { 20.days.ago }
      due_at { 6.days.ago }
      status { 'borrowed' }
    end

    trait :returned do
      returned_at { Time.current }
      status { 'returned' }
    end
  end
end
