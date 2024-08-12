class AddHistoryColumnsToLocationHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :location_histories, :aisle, :integer
    add_column :location_histories, :rack, :integer
    add_column :location_histories, :bin, :integer
  end
end
