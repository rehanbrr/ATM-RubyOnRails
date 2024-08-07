class RemoveStatusFromTransactions < ActiveRecord::Migration[7.1]
  def change
    remove_column :transactions, :status
  end
end
