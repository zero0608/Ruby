class AddReserveToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :reserve, :boolean
  end
end
