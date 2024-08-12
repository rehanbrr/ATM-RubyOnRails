class Account < ApplicationRecord

  CURRENCIES = ['PKR', 'USD', 'SAR'].freeze

  enum status: {
    active: 1,
    blocked: 2
  }, _default: :active

  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :pin, presence: true, format: { with: /\A\d{4}\z/, message: 'Must be exactly 4 digits' }
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true, inclusion: { in: CURRENCIES }

  def valid_transfer?(recipient, amount)
    sufficient_balance?(amount) && recipient&.currency == currency && recipient&.active?
  end

  def sufficient_balance?(amount)
    amount <= balance
  end

  def give_notice(recipient, amount)
    if !recipient
      'Account does not exist'
    elsif !sufficient_balance?(amount)
      'Insufficient Balance'
    elsif recipient.currency != currency
      'Cannot transfer to different currency'
    elsif recipient.blocked?
      'Cannot transfer to blocked account'
    end
  end

  def create_transaction(amount, type, account = self)
    account.transactions.create!(user: account.user, amount:, transaction_type: Transaction.transaction_types[type])
  end
end
