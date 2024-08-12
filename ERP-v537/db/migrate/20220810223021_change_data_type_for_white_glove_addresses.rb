class ChangeDataTypeForWhiteGloveAddresses < ActiveRecord::Migration[6.1]
  def change
    drop_table :white_glove_directories
    remove_column :white_glove_addresses, :shipping_detail_id, :bigint
    remove_column :white_glove_addresses, :last_name, :string
    rename_column :white_glove_addresses, :first_name, :contact
    add_reference :shipping_details, :white_glove_address, foreign_key: true
  end
end
