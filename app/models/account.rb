class Account < ApplicationRecord
  after_initialize :set_default_status, if: :new_record?

  CURRENCIES = ['PKR', 'USD', 'SAR'].freeze

  enum status: {
    active: 1,
    blocked: 2
  }

  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :pin, presence: true, format: { with: /\A\d{4}\z/, message: 'Must be exactly 4 digits' }
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true, inclusion: { in: CURRENCIES }

  def valid_transfer?(recipient, amount)
    return false unless recipient

    sufficient_balance?(amount) && recipient.currency == currency && recipient.status != 'blocked'
  end

  def sufficient_balance?(amount)
    amount <= balance
  end

  def give_notice(recipient, amount)
    return 'Account does not exist' unless recipient

    if !sufficient_balance?(amount)
      'Insufficient Balance'
    elsif recipient.currency != currency
      'Cannot transfer to different currency'
    elsif recipient.status == 'blocked'
      'Cannot transfer to blocked account'
    end
  end

  def create_transaction(amount, type, account = self)
    account.transactions.create!(user: account.user, amount:, transaction_type: Transaction.transaction_types[type])
  end

  def set_default_status
    self.status ||= :active
  end
end
