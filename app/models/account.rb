class Account < ApplicationRecord
  STATUSES = ['Active', 'Blocked']
  CURRENCIES = ['PKR', 'USD', 'SAR']

  belongs_to :user
  has_many :transactions, foreign_key: :account_number, dependent: :destroy

  validates :status, inclusion: {in: STATUSES}
  validates :pin, presence: true, format: { with: /\A\d{4}\z/, message: 'Must be exactly 4 digits' }
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true, inclusion: {in: CURRENCIES}

  self.primary_key = 'account_number'
end
