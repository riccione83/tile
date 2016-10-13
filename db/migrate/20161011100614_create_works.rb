class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.integer :price_id
      t.string :location

      t.timestamps null: false
    end
  end
end
