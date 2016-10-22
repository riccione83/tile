class AddPaymentIdToWork < ActiveRecord::Migration
  def change
    add_column :works, :payment_id, :integer
  end
end
