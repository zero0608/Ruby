class AddHoldReasonToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :hold_reason, :string
  end
end
