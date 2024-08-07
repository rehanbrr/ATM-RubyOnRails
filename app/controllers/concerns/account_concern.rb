module AccountConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_account, only: [:show, :update, :destroy, :deposit, :withdraw, :verify_pin, :send_money, :change_status]
  end

  def set_account
    @account = Account.find(params[:id] || params[:account_id])
    return if @account

    redirect_to accounts_path, notice: 'Account not found'
  end

  def find_account(account_id)
    Account.find(account_id)
  end
end
