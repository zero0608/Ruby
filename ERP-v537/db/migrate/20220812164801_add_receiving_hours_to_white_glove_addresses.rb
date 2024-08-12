class AddReceivingHoursToWhiteGloveAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :white_glove_addresses, :receiving_hours, :string
  end
end
