class RemoveDiscountCodesFromOrder < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :discount_codes, :string
  end
end
