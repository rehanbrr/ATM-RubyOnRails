FactoryBot.define do
  factory :account do
    pin { '1234' }
    balance { 1234.43 }
    association :user
    currency { 'SAR' }

    transient do
      pin_wrong { false }
      balance_wrong { false }
      currency_wrong { false }
    end

    after(:build) do |account, evaluator|
      account.pin = '12' if evaluator.pin_wrong
      account.balance = 'twenty' if evaluator.balance_wrong
      account.currency = 'EUR' if evaluator.currency_wrong
    end
  end

  trait :active do
    status { 1 }
  end

  trait :blocked do
    status { 2 }
  end
end
