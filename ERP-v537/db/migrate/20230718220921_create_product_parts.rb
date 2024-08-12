class CreateProductParts < ActiveRecord::Migration[6.1]
  def change
    create_table :product_parts do |t|
      t.string :name

      t.timestamps
    end
  end
end
