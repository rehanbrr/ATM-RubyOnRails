class Transaction < ApplicationRecord
  belongs_to :account, foreign_key: :account_number, primary_key: :account_number
  belongs_to :user
end
