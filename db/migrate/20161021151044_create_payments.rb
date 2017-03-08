class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :work_id
      t.integer :user_id
      t.string :status
      t.string :transaction_id
      t.datetime :purchased_at
      t.string :notification_params

      t.timestamps null: false
    end
  end
  def change
      change_column :works, :notification_params
      change_column :works, :closed
      change_column :works, :accepted_by
      change_column :works, :purchased_at
      change_column :works, :transaction_id
      change_column :works, :status
  end
end