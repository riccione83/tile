class AddCategoriesToWorks < ActiveRecord::Migration
  def change
    add_column :works, :categories, :string
  end
end
