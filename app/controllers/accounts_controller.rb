class AccountsController < ApplicationController
  def index
    @accounts = current_user.accounts
  end

  def show
    @account = Account.find(params[:account_number])
  end

  def new
    account = Account.order(:account_number).last
    !account ? next_number = 0 : next_number = account.account_number.to_i + 1
    @account = current_user.accounts.build(account_number: next_number)
  end

  def create
    @account = current_user.accounts.build(account_params)
    if @account.save
      redirect_to @account, method: :get
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    render :edit, status: :unprocessable_entity unless @account.user == current_user

    @account.update(account_params) ? redirect_to(@account) : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy!

    redirect_to account_index_path, notice: "Account deleted successfully"
  end


  private

  def account_params
    params.require(:account).permit(:account_number, :pin, :balance, :status, :currency)
  end
end
