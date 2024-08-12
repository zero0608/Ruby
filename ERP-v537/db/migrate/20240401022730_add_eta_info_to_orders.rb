class AddEtaInfoToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :eta_from, :string
    add_column :orders, :eta_to, :string
  end
end
