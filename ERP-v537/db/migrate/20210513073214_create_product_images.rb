class CreateProductImages < ActiveRecord::Migration[6.1]
  def change
    create_table :product_images do |t|
      t.string :shopify_image_id
      t.integer :position
      t.string :alt
      t.string :width
      t.string :height
      t.string :src
      t.text :variant_ids, array: true, default: []
      t.string :admin_graphql_api_id
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
