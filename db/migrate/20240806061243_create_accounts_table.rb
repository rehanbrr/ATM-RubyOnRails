class CreateAccountsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: false do |t|
      t.string :account_number, primary_key: true
      t.string :pin
      t.decimal :balance, precision: 10, scale: 2
      t.string :status
      t.string :currency
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
