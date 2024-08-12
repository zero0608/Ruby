class AddWarehouseInfoInLIneItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :line_items, :warehouse, foreign_key: true
    add_reference :line_items, :warehouse_variant, foreign_key: true
  end
end
