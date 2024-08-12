class AddMaterialListToSwatchProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :swatch_products, :material_list, foreign_key: true, null: true
  end
end
