class AddAccepteduserClosedAtWorks < ActiveRecord::Migration
  def change
    add_column :works, :accepted_by, :integer
    add_column :works, :closed, :integer, :default => 0
  end
end
