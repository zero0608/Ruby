class AddDiscountedPriceToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :discounted_price, :string
  end
end
