class TransactionsController < ApplicationController
  before_action :set_account
  def index
    @transactions = @account.transactions
  end

  private

  def set_account
    @account = Account.find_by(account_number: params[:account_account_number])
    return if @account

    redirect_to accounts_path, notice: 'Account not found'
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :transaction_type)
  end
end
