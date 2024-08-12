class AddStagingDateToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :staging_date, :date
  end
end
