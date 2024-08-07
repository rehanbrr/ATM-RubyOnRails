class Account < ApplicationRecord
  after_initialize :set_default_status, if: :new_record?
  
  CURRENCIES = ['PKR', 'USD', 'SAR'].freeze

  enum status: {
    active: 1,
    blocked: 2,
  }

  belongs_to :user
  has_many :transactions, foreign_key: :account_number, dependent: :destroy

  validates :pin, presence: true, format: { with: /\A\d{4}\z/, message: 'Must be exactly 4 digits' }
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true, inclusion: { in: CURRENCIES }

  self.primary_key = 'account_number'

  def valid_transfer?(recipient, amount)
    sufficient_balance?(amount) && recipient.currency == currency && recipient.status != 'Blocked'
  end

  def sufficient_balance?(amount)
    amount <= balance
  end

  def give_notice(recipient, amount)
    if !sufficient_balance?(amount)
      'Insufficient Balance'
    elsif recipient.currency != self.currency
      'Cannot transfer to different currency'
    elsif recipient.status == 'Blocked'
      'Cannot transfer to blocked account'
    elsif !recipient
      'Account does not exist'
    end
  end

  def create_transaction(amount, type, account = self)
    account.transactions.create!(user: account.user, amount:, transaction_type: Transaction.transaction_types[type])
  end

  def set_default_status
    self.status ||= :active
  end
end
