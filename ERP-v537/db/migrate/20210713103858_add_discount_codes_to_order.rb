class AddDiscountCodesToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :discount_codes, :json
  end
end
