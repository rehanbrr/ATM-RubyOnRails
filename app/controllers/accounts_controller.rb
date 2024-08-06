class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :withdraw, :deposit, :verify_pin, :send_money, :change_status]
  before_action :authorize_account, only: [:show, :edit, :update, :destroy, :verify_pin, :withdraw, :deposit, :send_money, :change_status]
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
    @account.delete

    redirect_to accounts_path, notice: 'Account deleted successfully'
  end

  def withdraw
    if request.post?
      amount = params[:amount].to_f
      if @account.balance >= amount
        @account.update(balance: @account.balance - amount)
        create_transaction(amount, 'withdraw')
        redirect_to @account, notice: 'Withdrawal successful'
      else
        flash[:alert] = 'Insufficient balance'
        render :withdraw
      end
    end
  end

  def deposit
    if request.post?
      amount = params[:amount].to_f
      if amount > 0
        @account.update(balance: @account.balance + amount)
        create_transaction(amount, 'deposit')
        redirect_to @account, notice: 'Deposit successful'
      else
        flash[:alert] = 'Deposit amount must be positive'
        render :deposit
      end
    end
  end

  def verify_pin
    if request.post?
      if @account.pin == params[:pin]
        redirect_to @account
      else
        flash[:alert] = "Invalid PIN"
        redirect_to accounts_path
      end
    end
  end

  def send_money
    if request.post?
      amount = params[:amount].to_f
      
      if Account.exists?(account_number: params[:recipient_account]) && amount <= @account.balance
        @recipient_account = Account.find_by(account_number: params[:recipient_account])
        if @recipient_account.currency == @account.currency
          unless @recipient_account.status == 'Blocked' || @account.status == 'Blocked'
            @recipient_account.update(balance: @recipient_account.balance + amount)
            @account.update(balance: @account.balance - amount)
            create_transaction(amount, 'send money')
            create_transaction(amount, 'received money', @recipient_account)
            redirect_to @account, notice: 'Money Transferred'
          else
            redirect_to accounts_path, notice: 'Cannot transfer to/from blocked accounts'
          end
        else
          redirect_to accounts_path, notice: 'Cannot transfer to different currency'
        end
      else
        redirect_to account_path, notice: 'Account does not exist or Insufficient Balance'
      end
    end
  end

  def change_status
    if request.post?
      @account.status == 'Active' ? @account.update(status: 'Blocked') : @account.update(status: 'Active')
      redirect_to @account
    end
  end

  private

  def create_transaction(amount, type, account = @account)
    account.transactions.create!(
      user: current_user,
      amount: amount,
      transaction_type: type
    )
  end

  def set_account
    @account = Account.find_by(account_number: params[:account_number])
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
