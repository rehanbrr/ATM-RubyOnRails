module AccountConcern
  extend ActiveSupport::Concern

  def set_account
    @account = Account.find(params[:id] || params[:account_id])
    redirect_to accounts_path, notice: 'Account not found' unless @account
  end

  def find_account(account_id)
    Account.find(account_id)
  end
end
