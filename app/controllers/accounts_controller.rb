class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :withdraw, :deposit, :verify_pin]
  def index
    @accounts = current_user.accounts
  end

  def show
  end

  def new
    account = Account.order(:account_number).last
    next_number = account ? account.account_number.to_i + 1 : 0
    @account = current_user.accounts.build(account_number: next_number)
  end

  def create
    @account = current_user.accounts.build(account_params)
    if @account.save
      redirect_to @account
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

  def withdraw
    amount = params[:amount].to_f
    if @account.balance >= amount
      @account.update(balance: @account.balance - amount)
      redirect_to @account, notice: "Withdrawal successful"
    else
      flash[:alert] = "Insufficient balance"
      render :withdraw
    end
  end

  def deposit
    amount = params[:amount].to_f
    @account.update(balance: @account.balance + amount)
    redirect_to @account, notice: "Deposit successful"
  end

  def verify_pin
    if request.post?
      if @account.pin == params[:pin]
        redirect_to @account
      else
        flash[:alert] = "Invalid PIN"
        render :verify_pin
      end
    end
  end

  private

  def set_account
    @account = Account.find_by(account_number: params[:account_number])
    unless @account
      redirect_to accounts_path, notice: 'Account not found'
    end
  end

  def account_params
    params.require(:account).permit(:account_number, :pin, :balance, :status, :currency)
  end
end
