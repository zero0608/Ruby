class RenameColumnInProductVariants < ActiveRecord::Migration[6.1]
  def change
    rename_column :product_variants, :type, :product_category
  end
end
