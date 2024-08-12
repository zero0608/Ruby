class AddOldIdToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :old_shopify_order_id, :string
  end
end
