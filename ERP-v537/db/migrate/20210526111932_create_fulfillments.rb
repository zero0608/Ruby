class CreateFulfillments < ActiveRecord::Migration[6.1]
  def change
    create_table :fulfillments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :shopify_fulfillment_id
      t.string :admin_graphql_api_id
      t.string :location_id
      t.string :name
      t.json :receipt
      t.string :service
      t.string :shipment_status
      t.string :status
      t.string :tracking_company
      t.string :tracking_numbers, array: true, default: []
      t.string :tracking_urls, array: true, default: []


      t.timestamps
    end
  end
end