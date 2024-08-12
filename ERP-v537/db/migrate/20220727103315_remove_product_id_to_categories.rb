class RemoveProductIdToCategories < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :categories, :products
    remove_column :categories, :product_id
  end
end
