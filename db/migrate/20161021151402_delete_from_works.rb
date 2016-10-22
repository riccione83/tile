class DeleteFromWorks < ActiveRecord::Migration
  def change
      remove_column  :works, :notification_params
      remove_column  :works, :closed
      remove_column  :works, :accepted_by
      remove_column  :works, :purchased_at
      remove_column  :works, :transaction_id
      remove_column  :works, :status

  end
end
