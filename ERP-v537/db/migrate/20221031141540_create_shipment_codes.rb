class CreateShipmentCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :shipment_codes do |t|
      t.string :sku_for_discount

      t.timestamps
    end
  end
end
