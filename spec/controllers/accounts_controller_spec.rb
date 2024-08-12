require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:user) { build(:user) }
  let!(:account) { create(:account, user: user) }

  before do
    allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
  end

  context 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new valid account' do
        expect {
          post :create, params: { account: attributes_for(:account) }
        }.to change(Account, :count).by(1)
      end

      it 'redirects to the show account view' do
        post :create, params: { account: attributes_for(:account) }
        expect(response).to redirect_to(Account.last)
      end
    end

    # context 'with invalid attributes' do
    #   it 'does not create a new account' do
    #     byebug
    #     expect {
    #       post :create, params: { account: attributes_for(:account, pin_wrong: true) }
    #     }.to_not change(Account, :count)
    #   end

    #   it 'does not redirect to show account view' do
    #     post :create, params: { account: attributes_for(:account, pin_wrong: true) }
    #     expect(response).to render_template(:new)
    #   end
    # end
  end

  context 'PATCH #change_status' do
    context 'when the account is active' do
      before { account.update(status: :active) }

      it 'changes the status to blocked' do
        patch :change_status, params: { id: account.id }
        expect(account.reload.status).to eq('blocked')
      end
    end

    context 'when the account is active' do
      before { account.update(status: :blocked) }

      it 'changes the status to active' do
        patch :change_status, params: { id: account.id }
        expect(account.reload.status).to eq('active')
      end
    end
  end

  context 'POST #withdraw' do
    before do
      account.update(balance: initial_balance)
    end

    context 'when there is sufficient balance' do
      let(:initial_balance) { 1000.00 }

      it 'reduces the account balance by the withdrawal amount' do
        expect {
          post :withdraw, params: { id: account.id, amount: 500.00 }
        }.to change { account.reload.balance }.by(-500.00)
      end

      it 'creates a withdrawal transaction' do
        expect {
          post :withdraw, params: { id: account.id, amount: 500.00 }
        }.to change(Transaction, :count).by(1)
      end

      it 'redirects to the show account view with success notice' do
        post :withdraw, params: { id: account.id, amount: 500.00 }
        expect(response).to redirect_to(account)
        expect(flash[:notice]).to eq('Withdrawal successful')
      end
    end

    context 'when there is insufficient balance' do
      let(:initial_balance) { 1000.00 }

      it 'does not change the account balance' do
        post :withdraw, params: { id: account.id, amount: 1500.00 }
        expect(account.reload.balance).to eq(initial_balance)
      end

      it 'does not create a new transaction' do
        expect {
          post :withdraw, params: { id: account.id, amount: 1500.00 }
        }.to_not change(Transaction, :count)
      end

      it 'redirects to the show account view with alert' do
        post :withdraw, params: { id: account.id, amount: 1500.00 }
        expect(response).to redirect_to(account)
        expect(flash[:alert]).to eq('Insufficient balance')
      end
    end

    context 'when a transaction fails' do
      let(:initial_balance) { 1000.00 }

      before do
        allow_any_instance_of(Account).to receive(:update).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'does not change the account balance' do
        expect {
          post :withdraw, params: { id: account.id, amount: 500.00 }
        }.to_not(change { account.reload.balance })
      end

      it 'does not create a new transaction' do
        expect {
          post :withdraw, params: { id: account.id, amount: 500.00 }
        }.to_not change(Transaction, :count)
      end

      it 'redirects to the show account view with an error message' do
        post :withdraw, params: { id: account.id, amount: 500.00 }
        expect(response).to redirect_to(account)
        expect(flash[:alert]).to eq('Transaction failed. Please try again.')
      end
    end
  end
end
