class AddCascadeDeleteToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :transactions, :accounts, column: :account_number, primary_key: :account_number, on_delete: :cascade
  end
end
