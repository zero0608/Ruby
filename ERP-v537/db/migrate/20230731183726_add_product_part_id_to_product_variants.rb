class AddProductPartIdToProductVariants < ActiveRecord::Migration[6.1]
  def change
    remove_column :replacement_references, :replacement_id, :integer
    
    drop_table :replacements do |t|
      t.references :product_part
      t.string :description
      t.integer :quantity
      t.timestamps
    end

    add_reference :product_variants, :product_part, foreign_key: true
    add_reference :line_items, :replacement_reference, foreign_key: true
  end
end
