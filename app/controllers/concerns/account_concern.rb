module AccountConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_account, only: [:show, :edit, :update, :destroy, :withdraw, :deposit, :verify_pin, :send_money, :change_status, :check_pin]
  end

  def set_account
    @account = find_account(params[:account_number])
    unless @account
      redirect_to accounts_path, notice: 'Account not found'
    end
  end

  def find_account(account_number)
    Account.find_by(account_number: account_number)
  end
end