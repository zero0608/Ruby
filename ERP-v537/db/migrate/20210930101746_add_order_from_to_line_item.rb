class AddOrderFromToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :order_from, :string
  end
end
