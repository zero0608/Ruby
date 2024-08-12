class CreateRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :refunds do |t|
      t.references :order, null: false, foreign_key: true
      t.string :shopify_refund_id
      t.string :admin_graphql_api_id
      t.string :note
      t.string :restock
      t.string :duties, array: true, default: []

      t.timestamps
    end
  end
end
