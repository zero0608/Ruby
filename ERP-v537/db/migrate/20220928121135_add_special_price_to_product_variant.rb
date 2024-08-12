class AddSpecialPriceToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :special_price, :string
  end
end
