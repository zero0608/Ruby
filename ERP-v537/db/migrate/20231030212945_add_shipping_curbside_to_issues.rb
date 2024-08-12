class AddShippingCurbsideToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :shipping_curbside, :string
    add_column :issues, :shipping_wgd, :string
  end
end
