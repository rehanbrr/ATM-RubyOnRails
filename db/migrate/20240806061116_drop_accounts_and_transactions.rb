class DropAccountsAndTransactions < ActiveRecord::Migration[7.1]
  def change
    drop_table :transactions, if_exists: true
    drop_table :accounts, if_exists: true
  end
end
