class AddSalesStatusToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :sales_status, :integer
  end
end
