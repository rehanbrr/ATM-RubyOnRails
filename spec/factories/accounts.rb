FactoryBot.define do
  factory :account do
    balance { 1000.0 }
    pin { '1234' }
    status { :active }
    currency { 'USD' }
    association :user

    transient do
      with_transactions { false }
    end

    after(:create) do |account, evaluator|
      create_list(:transaction, 2, account: account) if evaluator.with_transactions
    end
  end
end