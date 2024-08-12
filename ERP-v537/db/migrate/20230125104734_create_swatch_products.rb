class CreateSwatchProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :swatch_products do |t|
      t.string :description
      t.string :swatch_sku
      t.string :store

      t.timestamps
    end
  end
end
