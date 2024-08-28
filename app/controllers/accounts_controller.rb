class AccountsController < ApplicationController
  include AccountConcern
  before_action :set_account, except: [:index, :create, :new]
  before_action :authorize_account, except: [:index, :create, :new]

  def index
    @accounts = current_user.accounts.paginate(page: params[:page], per_page: 3)
    return unless params[:form_type].eql?('verify_pin') && params[:account_id]

    @account = Account.find_by(id: params[:account_id])
  end

  def new
    @account = current_user.accounts.build(status: :active)
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
    if @account.destroy
      redirect_to accounts_path, notice: 'Account deleted successfully'
    else
      redirect_to accounts_path, notice: 'Problem deleting account'
    end
  end

  def change_status
    new_status = @account.active? ? :blocked : :active
    @account.update(status: new_status)
    redirect_to @account
  end

  def withdraw
    amount = params[:amount].to_f

    ActiveRecord::Base.transaction do
      @account.lock!
      if @account.sufficient_balance?(amount)
        @account.update(balance: @account.balance - amount)
        @account.create_transaction(amount, :withdraw)
        redirect_to @account, notice: 'Withdrawal successful'
      else
        flash[:alert] = 'Insufficient balance'
        redirect_to @account
      end
    end
  rescue ActiveRecord::StaleObjectError, ActiveRecord::RecordInvalid
    flash[:alert] = 'Transaction failed. Please try again.'
    redirect_to @account
  end

  def deposit
    amount = params[:amount].to_f
    return unless amount.positive?

    ActiveRecord::Base.transaction do
      @account.lock!
      @account.update!(balance: @account.balance + amount)
      @account.create_transaction(amount, :deposit)
      redirect_to @account, notice: 'Deposit successful'
    end
  rescue ActiveRecord::StaleObjectError, ActiveRecord::RecordInvalid
    flash[:alert] = 'Transaction failed. Please try again.'
    redirect_to @account
  end

  def verify_pin
    if @account.pin == params[:pin]
      redirect_to @account
    else
      flash[:alert] = 'Invalid PIN'
      redirect_to accounts_path(form_type: 'verify_pin', account_id: params[:account_id])
    end
  end

  def send_money
    amount = params[:amount].to_f
    recipient = find_account(params[:recipient_account_id])
    ActiveRecord::Base.transaction do
      @account.lock!
      recipient.lock!
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
  rescue ActiveRecord::StaleObjectError, ActiveRecord::RecordInvalid
    flash[:alert] = 'Transaction failed. Please try again.'
    redirect_to @account
  end

  private

  def authorize_account
    return if @account.user == current_user

    redirect_to accounts_path, status: :unauthorized
  end

  def account_params
    params.require(:account).permit(:pin, :balance, :status, :currency)
  end
end
