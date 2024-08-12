class AddEtaToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :eta, :date
  end
end
