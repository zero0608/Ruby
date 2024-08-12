class AddEtaDateToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :eta_from, :date
    add_column :shipping_details, :eta_to, :date
    add_column :state_days, :name, :string
  end
end
