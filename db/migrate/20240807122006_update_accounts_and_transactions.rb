class UpdateAccountsAndTransactions < ActiveRecord::Migration[7.1]
  def change
    # Step 1: Remove foreign key constraints
    remove_foreign_key :transactions, :accounts

    # Step 2: Remove the account_number column and primary key constraint from accounts
    remove_column :accounts, :account_number, :string

    # Step 3: Add the id column as the primary key to accounts
    add_column :accounts, :id, :primary_key

    # Step 4: Add the account_id column to transactions, initially allowing null values
    add_column :transactions, :account_id, :integer

    # Step 5: Update the existing transactions to set the correct account_id
    execute <<-SQL
      UPDATE transactions
      SET account_id = (
        SELECT id FROM accounts
        WHERE accounts.id = transactions.account_number
      )
    SQL

    # Step 6: Change the account_id column to not allow null values
    change_column_null :transactions, :account_id, false

    # Step 7: Add the foreign key constraint to transactions for account_id
    add_foreign_key :transactions, :accounts, column: :account_id, on_delete: :cascade

    # Step 8: Remove the old account_number column from transactions
    remove_column :transactions, :account_number, :integer
  end
end
