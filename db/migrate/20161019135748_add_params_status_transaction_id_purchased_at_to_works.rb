class AddParamsStatusTransactionIdPurchasedAtToWorks < ActiveRecord::Migration
  def change
    add_column :works, :notification_params, :text
    add_column :works, :status, :string
    add_column :works, :transaction_id, :string
    add_column :works, :purchased_at, :datetime
  end
end
