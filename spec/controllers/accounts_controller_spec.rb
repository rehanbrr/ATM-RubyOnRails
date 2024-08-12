require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }

  before do
    allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:account_params) { attributes_for(:account, user: user) }

      it 'saves the new account in the database' do
        post :create, params: { account: account_params }
        new_account = assigns(:account)

        expect(new_account).to be_persisted
        expect(new_account.user).to eq(user)
        expect(new_account.balance).to eq(account_params[:balance])
        expect(new_account.pin).to eq(account_params[:pin])
      end

      it 'redirects to the new account' do
        post :create, params: { account: account_params }
        expect(response).to redirect_to(account_path(assigns(:account)))
      end
    end

    context 'with invalid attributes' do
      let(:invalid_account_params) { attributes_for(:account, balance: nil) }

      it 'does not save the new account in the database' do
        post :create, params: { account: invalid_account_params }
        expect(assigns(:account)).not_to be_persisted
      end

      it 're-renders the new template' do
        post :create, params: { account: invalid_account_params }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the account' do
      delete :destroy, params: { id: account.id }
      expect(Account.exists?(account.id)).to be_falsey
    end

    it 'redirects to accounts path' do
      delete :destroy, params: { id: account.id }
      expect(response).to redirect_to(accounts_path)
    end
  end

  describe 'PATCH #change_status' do
    it 'toggles the account status' do
      original_status = account.status
      patch :change_status, params: { id: account.id }
      account.reload
      expect(account.status).not_to eq(original_status)
    end

    it 'redirects to the account after changing status' do
      patch :change_status, params: { id: account.id }
      expect(response).to redirect_to(account)
    end
  end

  describe 'POST #withdraw' do
    let(:amount) { 50.0 }

    it 'deducts the amount from the account balance when the balance is sufficient' do
      original_balance = account.balance
      post :withdraw, params: { id: account.id, amount: amount }
      account.reload
      expect(account.balance).to eq(original_balance - amount)
    end

    it 'creates a withdrawal transaction' do
      post :withdraw, params: { id: account.id, amount: amount }
      transaction = account.transactions.last
      expect(transaction.amount).to eq(amount)
      expect(transaction.transaction_type).to eq('withdraw')
    end

    context 'when the balance is insufficient' do
      it 'does not change the balance' do
        post :withdraw, params: { id: account.id, amount: account.balance + 100 }
        expect(account.reload.balance).to eq(account.balance)
      end

      it 'redirects to the account with an alert' do
        post :withdraw, params: { id: account.id, amount: account.balance + 100 }
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(account)
      end
    end
  end

  describe 'POST #deposit' do
    let(:amount) { 100.0 }

    it 'adds the amount to the account balance' do
      original_balance = account.balance
      post :deposit, params: { id: account.id, amount: amount }
      account.reload
      expect(account.balance).to eq(original_balance + amount)
    end

    it 'creates a deposit transaction' do
      post :deposit, params: { id: account.id, amount: amount }
      transaction = account.transactions.last
      expect(transaction.amount).to eq(amount)
      expect(transaction.transaction_type).to eq('deposit')
    end
  end

  describe 'POST #send_money' do
    let(:recipient) { create(:user, :recipient) }
    let(:recipient_account) { create(:account, user: recipient) }
    let(:amount) { 50.0 }

    context 'when the transfer is valid' do
      it 'transfers the amount to the recipient' do
        recipient_balance = recipient_account.balance
        account_balance = account.balance
        post :send_money, params: { id: account.id, recipient_account_id: recipient_account.id, amount: amount }
        recipient_account.reload
        account.reload
        expect(recipient_account.balance).to eq(recipient_balance + amount)
        expect(account.balance).to eq(account_balance - amount)
      end

      it 'creates a send_money and received_money transaction' do
        post :send_money, params: { id: account.id, recipient_account_id: recipient_account.id, amount: amount }

        send_transaction = account.transactions.find_by(transaction_type: :send_money, amount: amount)
        receive_transaction = recipient_account.transactions.find_by(transaction_type: :received_money, amount: amount)

        expect(send_transaction).not_to be_nil
        expect(receive_transaction).not_to be_nil

        expect(send_transaction.amount).to eq(amount)
        expect(send_transaction.transaction_type).to eq('send_money')

        expect(receive_transaction.amount).to eq(amount)
        expect(receive_transaction.transaction_type).to eq('received_money')
      end
    end

    context 'when the transfer is invalid' do
      it 'does not transfer the amount' do
        account_balance = account.balance
        post :send_money, params: { id: account.id, recipient_account_id: recipient_account.id, amount: account.balance + 100 }
        recipient_account.reload
        account.reload
        expect(recipient_account.balance).to eq(1000.0)
        expect(account.balance).to eq(account_balance)
      end
    end
  end
end
