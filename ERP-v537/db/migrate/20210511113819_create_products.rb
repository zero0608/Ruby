class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :shopify_product_id
      t.string :title
      t.text :body_html
      t.string :vendor
      t.string :product_type
      t.string :handle
      t.string :template_suffix
      t.string :status
      t.string :published_scope
      t.string :admin_graphql_api_id
      t.text :tags
      t.datetime :published_at

      t.timestamps
    end
  end
end
