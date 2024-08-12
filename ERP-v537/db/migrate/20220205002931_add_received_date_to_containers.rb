class AddReceivedDateToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :received_date, :date
  end
end