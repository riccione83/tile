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

end