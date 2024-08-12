class EditChargesInShippingDetails < ActiveRecord::Migration[6.1]
  def change
    remove_column :shipping_details, :fuel_surcharge, :string
    remove_column :shipping_details, :tax, :string
    add_column :shipping_details, :actual_invoiced, :string
    add_column :shipping_details, :white_glove_fee, :string
  end
end
