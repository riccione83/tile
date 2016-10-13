class ModifyDescriptionWork < ActiveRecord::Migration
  def change
    change_column :works, :description,  :text
  end
end
