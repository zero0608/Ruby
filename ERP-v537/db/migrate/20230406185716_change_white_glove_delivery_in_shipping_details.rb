class ChangeWhiteGloveDeliveryInShippingDetails < ActiveRecord::Migration[6.1]
  def change
    change_column :shipping_details, :white_glove_delivery, :boolean, :using => "case white_glove_delivery when \'1\' then true else false end"
  end
end
