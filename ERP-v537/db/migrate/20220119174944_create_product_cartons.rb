class CreateProductCartons < ActiveRecord::Migration[6.1]
  def change
    create_table :product_cartons do |t|
      t.references :product_variant, null: false, foreign_key: true

      t.string :carton_length
      t.string :carton_width
      t.string :carton_height
      t.string :carton_weight

      t.timestamps
    end

    
  end
end
