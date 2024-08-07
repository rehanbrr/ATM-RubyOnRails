class AccountsController < ApplicationController
  include AccountConcern
  before_action :authorize_account, only: [:show, :edit, :update, :destroy, :deposit, :withdraw, :verify_pin, :send_money, :change_status]
  def index
    @accounts = current_user.accounts
    if params[:form_type] == 'verify_pin' && params[:account_number]
      @account = Account.find_by(account_number: params[:account_number])
    end
  end

  def new
    account = Account.order(:account_number).last
    next_number = account ? account.account_number + 1 : 0
    @account = current_user.accounts.build(account_number: next_number, status: :active)
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
  end

  def update
    @account.update(account_params) ? redirect_to(@account) : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @account.delete
    redirect_to accounts_path, notice: 'Account deleted successfully'
  end

  def change_status
    @account.status == :active ? @account.update(status: :blocked) : @account.update(status: :active)
    redirect_to @account
  end

  def withdraw
    amount = params[:amount].to_f
    if Account.sufficient_balance?(amount, @account)
      @account.update(balance: @account.balance - amount)
      Account.create_transaction(amount, :withdraw, @account, current_user)
      redirect_to @account, notice: 'Withdrawal successful'
    else
      flash[:alert] = 'Insufficient balance'
      render :withdraw
    end
  end

  def deposit
    amount = params[:amount].to_f
    if amount > 0
      @account.update(balance: @account.balance + amount)
      Account.create_transaction(amount, :deposit, @account, current_user)
      redirect_to @account, notice: 'Deposit successful'
    else
      flash[:alert] = 'Deposit amount must be positive'
      render :deposit
    end
  end

  def verify_pin
    if @account.pin == params[:pin]
      redirect_to @account
    else
      flash[:alert] = "Invalid PIN"
      redirect_to accounts_path(form_type: 'verify_pin', account_number: params[:account_number])
    end
  end

  def send_money
    amount = params[:amount].to_f
    recipient = find_account(params[:recipient_account])
    if Account.valid_transfer?(recipient, amount, @account)
      recipient.update(balance: recipient.balance + amount)
      @account.update(balance: @account.balance - amount)

      Account.create_transaction(amount, :send_money, @account, current_user)
      Account.create_transaction(amount, :received_money, recipient, current_user)
      redirect_to @account, notice: 'Money Transferred'
    else
      redirect_to @account, notice: Account.give_notice(recipient, amount, @account)
    end
  end


  private
  def create_transaction(amount, type, account)
    account.transactions.create!(
      user: current_user,
      amount: amount,
      transaction_type: type
    )
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
