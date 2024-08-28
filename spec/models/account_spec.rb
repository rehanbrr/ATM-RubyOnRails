require 'rails_helper'

RSpec.describe Account, type: :model do
  subject { Account.new(pin: '1234', balance: 1045, status: 'active', currency: 'USD', user_id: 3) }

  it 'is valid with attributes' do
    expect(subject).to be_valid
  end

  it 'is valid with pin being digits' do
    expect((subject.pin).match?(/\A-?\d+\Z/)).to eq(true)
  end

  it 'is valid with pin being 4 digits' do
    expect((subject.pin).length).to eq(4)
  end
end
