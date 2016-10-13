class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :user_id
      t.integer :work_id
      t.float :price

      t.timestamps null: false
    end
  end
end
