class CreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.string :shopify_customer_id
      t.string :email
      t.string :accpts_marketing
      t.string :first_name
      t.string :last_name
      t.string :orders_count
      t.string :state
      t.string :total_spent
      t.string :last_order_id
      t.string :note
      t.string :verified_email
      t.string :multipass_identifier
      t.string :tax_exempt
      t.string :phone
      t.string :tags
      t.string :last_order_name
      t.string :currency
      t.string :accepts_marketing_updated_at
      t.string :marketing_opt_in_level
      t.string :tax_exemptions, array: true, default: []
      t.string :admin_graphql_api_id
      t.json :default_address
      t.json :metfield

      t.timestamps
    end
  end
end
