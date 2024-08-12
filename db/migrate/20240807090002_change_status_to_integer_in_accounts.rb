class ChangeStatusToIntegerInAccounts < ActiveRecord::Migration[7.1]
  def change
    change_column :accounts, :status, :integer
  end
end
