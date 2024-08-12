FactoryBot.define do
  factory :user do
    sequence(:id) { |n| n }
    email { 'test123@example.com' }
    password { 'test1234' }
    password_confirmation { 'test1234' }
  end
end
