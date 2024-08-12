class AddCancelColumnsToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :cancel_request_date, :datetime
    add_column :orders, :cancelled_date, :datetime
  end
end
