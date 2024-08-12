class RemoveInfoFromWhiteGloveAddresses < ActiveRecord::Migration[6.1]
  def change
    remove_column :white_glove_addresses, :country_code, :string
    remove_column :white_glove_addresses, :latitude, :string
    remove_column :white_glove_addresses, :longitude, :string
    remove_column :white_glove_addresses, :name, :string
    remove_column :white_glove_addresses, :province, :string
    remove_column :white_glove_addresses, :province_code, :string
  end
end