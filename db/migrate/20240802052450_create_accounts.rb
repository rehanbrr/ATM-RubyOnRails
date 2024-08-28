class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: false, primary_key: :account_number do |t|
      t.string :account_number
      t.string :pin
      t.decimal :balance
      t.string :status
      t.string :currency
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
