class AddShippingDetailIdToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :line_items, :shipping_detail, foreign_key: true, null: true
  end
end
