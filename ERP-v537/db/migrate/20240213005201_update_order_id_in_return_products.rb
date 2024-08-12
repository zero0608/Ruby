class UpdateOrderIdInReturnProducts < ActiveRecord::Migration[6.1]
  def change
    change_column_null :return_products, :order_id, true
    change_column_null :return_products, :line_item_id, true
  end
end
