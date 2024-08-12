class AddWarehouseIdToShowrooms < ActiveRecord::Migration[6.1]
  def change
    add_reference :showrooms, :warehouse, foreign_key: true
  end
end
