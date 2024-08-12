class AddNotesToWhiteGloveAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :white_glove_addresses, :notes, :string
    add_column :white_glove_addresses, :delivery_notification, :boolean
  end
end
