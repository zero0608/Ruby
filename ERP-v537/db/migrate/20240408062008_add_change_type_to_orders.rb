class AddChangeTypeToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :eta_data_from, :datetime
    add_column :orders, :eta_data_to, :datetime
  end
end
