class AccountsController < ApplicationController
  include AccountConcern
  before_action :authorize_account, only: [:show, :update, :destroy, :deposit, :withdraw, :verify_pin, :send_money, :change_status]

  def index
    @accounts = current_user.accounts.paginate(page: params[:page], per_page: 3)
    return unless params[:form_type].eql?('verify_pin') && params[:account_number]

    @account = Account.find_by(account_number: params[:account_number])
  end

  def new
    account = Account.order(:account_number).last
    next_number = account ? account.account_number + 1 : 0
    @account = current_user.accounts.build(account_number: next_number, status: :active)
  end

  def create
    account = current_user.accounts.build(account_params)
    if account.save
      redirect_to account
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @account.update(account_params) ? redirect_to(@account) : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    redirect_to accounts_path, notice: 'Problem deleting account' unless @account.destroy
    redirect_to accounts_path, notice: 'Account deleted successfully'
  end

  def change_status
    @account.active? ? @account.update(status: :blocked) : @account.update(status: :active)
    redirect_to @account
  end

  def withdraw
    amount = params[:amount].to_f

    if @account.sufficient_balance?(amount)
      @account.update(balance: @account.balance - amount)
      @account.create_transaction(amount, :withdraw)
      redirect_to @account, notice: 'Withdrawal successful'
    else
      flash[:alert] = 'Insufficient balance'
      render :withdraw
    end
  end

  def deposit
    amount = params[:amount].to_f
    if amount.positive?
      @account.update(balance: @account.balance + amount)
      @account.create_transaction(amount, :deposit)
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
      flash[:alert] = 'Invalid PIN'
      redirect_to accounts_path(form_type: 'verify_pin', account_number: params[:account_number])
    end
  end

  def send_money
    amount = params[:amount].to_f
    recipient = find_account(params[:recipient_account])
    if @account.valid_transfer?(recipient, amount)
      recipient.update(balance: recipient.balance + amount)
      @account.update(balance: @account.balance - amount)

      @account.create_transaction(amount, :send_money)
      @account.create_transaction(amount, :received_money, recipient)
      redirect_to @account, notice: 'Money Transferred'
    else
      redirect_to @account, notice: @account.give_notice(recipient, amount)
    end
  end

  private

  def authorize_account
    return if @account.user == current_user

    redirect_to accounts_path, notice: 'Not authorized to access this account'
  end

  def account_params
    params.require(:account).permit(:account_number, :pin, :balance, :status, :currency)
  end
end
