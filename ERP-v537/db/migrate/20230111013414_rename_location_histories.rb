class RenameLocationHistories < ActiveRecord::Migration[6.1]
  def change
    rename_column :location_histories, :rack, :level
    rename_column :location_histories, :aisle, :rack
  end
end
