class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :do_withdraw, :do_deposit, :deposit, :withdraw, :verify_pin, :send_money, :change_status, :check_pin]
  before_action :authorize_account, only: [:show, :edit, :update, :destroy, :do_withdraw, :do_deposit, :deposit, :withdraw, :verify_pin, :send_money, :change_status, :check_pin]
  def index
    @accounts = current_user.accounts
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

  def update
    @account.update(account_params) ? redirect_to(@account) : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @account.delete
    redirect_to accounts_path, notice: 'Account deleted successfully'
  end

  def do_withdraw
    amount = get_amount
    if sufficient_balance?(amount)
      @account.update(balance: @account.balance - amount)
      create_transaction(amount, 'withdraw')
      redirect_to @account, notice: 'Withdrawal successful'
    else
      flash[:alert] = 'Insufficient balance'
      render :withdraw
    end
  end

  def do_deposit
    amount = get_amount
    if amount > 0
      @account.update(balance: @account.balance + amount)
      create_transaction(amount, 'deposit')
      redirect_to @account, notice: 'Deposit successful'
    else
      flash[:alert] = 'Deposit amount must be positive'
      render :deposit
    end
  end

  def check_pin
    if @account.pin == params[:pin]
      redirect_to @account
    else
      flash[:alert] = "Invalid PIN"
      redirect_to accounts_path
    end
  end

  def transfer_money
    amount = get_amount
    recipient = find_account(params[:recipient_account])
    if valid_transfer?(recipient, amount)
      recipient.update(balance: recipient.balance + amount)
      @account.update(balance: @account.balance - amount)

      create_transaction(amount, 'send money')
      create_transaction(amount, 'received money', recipient)
      redirect_to @account, notice: 'Money Transferred'
    else
      redirect_to @account, notice: give_notice(recipient, amount)
    end
  end

  def change_status
    @account.status == 'Active' ? @account.update(status: 'Blocked') : @account.update(status: 'Active')
    redirect_to @account
  end

  def edit
  end

  def withdraw
  end

  def deposit
  end

  def verify_pin
  end

  def send_money
  end

  def send_money
  end

  private

  def give_notice(recipient, amount)
    if !sufficient_balance?(amount)
      'Insufficient Balance'
    elsif recipient.currency != @account.currency
      'Cannot transfer to different currency'
    elsif recipient.status == 'Blocked'
      'Cannot transfer to blocked account'
    elsif !recipient
      'Account does not exist'
    end
  end

  def valid_transfer?(recipient, amount)
    sufficient_balance?(amount) && recipient.currency == @account.currency && recipient.status != 'Blocked'
  end

  def sufficient_balance?(amount)
    amount <= @account.balance
  end

  def get_amount
    params[:amount].to_f
  end

  def create_transaction(amount, type, account = @account)
    account.transactions.create!(
      user: current_user,
      amount: amount,
      transaction_type: type
    )
  end

  def find_account(account_number)
    Account.find_by(account_number: account_number)
  end

  def set_account
    @account = find_account(params[:account_number])
    unless @account
      redirect_to accounts_path, notice: 'Account not found'
    end
  end

  def authorize_account
    unless @account.user == current_user
      redirect_to accounts_path, notice: 'Not authorized to access this account'
    end
  end

  def account_params
    params.require(:account).permit(:account_number, :pin, :balance, :status, :currency)
  end
end
