class CreateTransactionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :account_number
      t.decimal :amount, precision: 10, scale: 2
      t.string :transaction_type
      t.timestamps
    end

    add_foreign_key :transactions, :accounts, column: :account_number, primary_key: :account_number
  end
end
