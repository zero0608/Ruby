class AddWarehousedataToContainer < ActiveRecord::Migration[6.1]
  def change
    add_reference :containers, :warehouse, foreign_key: true, null: true
  end
end
