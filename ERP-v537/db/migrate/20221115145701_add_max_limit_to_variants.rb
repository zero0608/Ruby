class AddMaxLimitToVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :max_limit, :integer
  end
end
