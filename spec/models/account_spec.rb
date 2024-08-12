require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:user) { build(:user) }
  subject { build(:account, user: user) }

  context 'when validating' do
    it 'is valid with attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid if balance is a string' do
      subject.balance = 'twenty_thousand'
      expect(subject).to_not be_valid
    end
  end

  context 'functions in account model' do
    let(:recipient) { build(:user, id: 4) }
    let(:recipient_account) { build(:account, user: recipient) }

    it 'is valid if balance is sufficient, currency is same and recipient is active' do
      amount = 123
      expect(subject.sufficient_balance?(amount)).to be true
    end

    it 'is invalid if balance is insufficient and relevant notice is given' do
      amount = 12_345
      expect(subject.sufficient_balance?(amount)).to be false
      expect(subject.give_notice(recipient_account, amount)).to eq('Insufficient Balance')
    end

    it 'is invalid if recipient account is blocked' do
      recipient_account.status = :blocked
      amount = 123
      expect(subject.valid_transfer?(recipient_account, amount)).to be false
      expect(subject.give_notice(recipient_account, amount)).to eq('Cannot transfer to blocked account')
    end

    it 'is invalid if recipient accounts currency is not the same as sender' do
      recipient_account.currency = 'USD'
      amount = 123
      expect(subject.valid_transfer?(recipient_account, amount)).to be false
      expect(subject.give_notice(recipient_account, amount)).to eq('Cannot transfer to different currency')
    end
  end
end
