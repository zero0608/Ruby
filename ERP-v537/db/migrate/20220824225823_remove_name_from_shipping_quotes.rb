class RemoveNameFromShippingQuotes < ActiveRecord::Migration[6.1]
  def change
    remove_column :shipping_quotes, :name, :string
  end
end
