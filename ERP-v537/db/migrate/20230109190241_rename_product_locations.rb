class RenameProductLocations < ActiveRecord::Migration[6.1]
  def change
    rename_column :product_locations, :rack, :level
    rename_column :product_locations, :aisle, :rack
  end
end
