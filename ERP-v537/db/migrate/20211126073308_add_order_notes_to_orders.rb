class AddOrderNotesToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :order_notes, :text
  end
end
