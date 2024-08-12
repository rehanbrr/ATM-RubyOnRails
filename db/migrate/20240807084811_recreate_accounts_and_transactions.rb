class RecreateAccountsAndTransactions < ActiveRecord::Migration[7.1]
  def up
    drop_table :transactions
    drop_table :accounts

    create_table :accounts, primary_key: :account_number, id: :integer, force: :cascade do |t|
      t.string :pin
      t.decimal :balance, precision: 10, scale: 2
      t.string :status
      t.string :currency
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    create_table :transactions, force: :cascade do |t|
      t.integer :account_number
      t.decimal :amount, precision: 10, scale: 2
      t.integer :transaction_type
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :accounts, :users
    add_foreign_key :transactions, :accounts, column: :account_number, primary_key: :account_number, on_delete: :cascade
    add_foreign_key :transactions, :users
  end

  def down
    drop_table :transactions
    drop_table :accounts

    create_table :accounts, primary_key: :account_number, id: :string, force: :cascade do |t|
      t.string :pin
      t.decimal :balance, precision: 10, scale: 2
      t.string :status
      t.string :currency
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    create_table :transactions, force: :cascade do |t|
      t.string :account_number
      t.decimal :amount, precision: 10, scale: 2
      t.integer :transaction_type
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :accounts, :users
    add_foreign_key :transactions, :accounts, column: :account_number, primary_key: :account_number, on_delete: :cascade
    add_foreign_key :transactions, :users
  end
end
