class AddWhiteGloveCarrierToReturns < ActiveRecord::Migration[6.1]
  def change
    remove_column :returns, :shipping_carrier, :string
    add_reference :returns, :carrier, foreign_key: true
    add_column :returns, :white_glove_address, :string
  end
end