class Transaction < ApplicationRecord
  belongs_to :account, foreign_key: :account_number, primary_key: :account_number
  belongs_to :user

  enum transaction_type: {
    withdraw: 1,
    deposit: 2,
    send_money: 3,
    received_money: 4
  }
end
