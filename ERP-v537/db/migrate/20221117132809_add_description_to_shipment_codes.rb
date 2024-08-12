class AddDescriptionToShipmentCodes < ActiveRecord::Migration[6.1]
  def change
    add_column :shipment_codes, :description, :text
  end
end
