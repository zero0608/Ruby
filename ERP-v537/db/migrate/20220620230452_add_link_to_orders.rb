class AddLinkToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :order_link, :integer, array: true
  end
end