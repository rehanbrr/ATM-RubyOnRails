class TransactionsController < ApplicationController
  include AccountConcern
  before_action :set_account

  def index
    @transactions = @account.transactions
  end
end
