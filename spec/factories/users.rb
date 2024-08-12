FactoryBot.define do
  factory :user do
    email { 'test123@example.com' }
    password { 'test1234' }
    password_confirmation { 'test1234' }

    trait :with_account do
      after(:create) do |user|
        create(:account, user: user)
      end
    end

    trait :recipient do
      email { "recipient@example.com" }
    end
  end
end
