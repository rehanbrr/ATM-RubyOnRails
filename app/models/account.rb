class Account < ApplicationRecord
  STATUSES = ['Active', 'Blocked']
  CURRENCIES = ['PKR', 'USB', 'SAR']

  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: {in: STATUSES}
  validates :pin, presence: true, format: { with: /\d{4}\z/ }
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true, inclusion: {in: CURRENCIES}

  self.primary_key = 'account_number'
end
