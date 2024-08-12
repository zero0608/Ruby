class AddParentLineItemIdToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :parent_line_item_id, :string
  end
end
