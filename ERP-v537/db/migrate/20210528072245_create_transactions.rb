class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.references :refund, null: true, foreign_key: true
      t.string :shopify_transaction_id
      t.string :admin_graphql_api_id
      t.string :amount
      t.string :authorization
      t.string :currency
      t.string :device_id
      t.string :error_code
      t.string :gateway
      t.string :kind
      t.string :location_id
      t.string :message
      t.string :parent_id
      t.string :source_name
      t.string :status
      t.string :test
      t.string :user_id


      t.timestamps
    end
  end
end
