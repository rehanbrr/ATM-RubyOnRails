class Account < ApplicationRecord
  STATUSES = ['Active', 'Blocked']
  CURRENCIES = ['PKR', 'USD', 'SAR']
  enum status: {
    active: 1,
    blocked: 2,
  }

  belongs_to :user
  has_many :transactions, foreign_key: :account_number, dependent: :destroy

  validates :pin, presence: true, format: { with: /\A\d{4}\z/, message: 'Must be exactly 4 digits' }
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true, inclusion: {in: CURRENCIES}

  self.primary_key = 'account_number'

  def self.valid_transfer?(recipient, amount, account)
    sufficient_balance?(amount, account) && recipient.currency == account.currency && recipient.status != 'Blocked'
  end

  def self.sufficient_balance?(amount, account)
    amount <= account.balance
  end

  def self.give_notice(recipient, amount, account)
    if !sufficient_balance?(amount, account)
      'Insufficient Balance'
    elsif recipient.currency != account.currency
      'Cannot transfer to different currency'
    elsif recipient.status == 'Blocked'
      'Cannot transfer to blocked account'
    elsif !recipient
      'Account does not exist'
    end
  end

  def self.create_transaction(amount, type, account, user)
    account.transactions.create!(
      user: user,
      amount: amount,
      transaction_type: Transaction.transaction_types[type]
    )
  end
end
