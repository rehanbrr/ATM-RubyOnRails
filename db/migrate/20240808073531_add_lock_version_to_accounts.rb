class AddLockVersionToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :lock_version, :integer, default: 0, null: false
  end
end
