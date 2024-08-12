class EditLengthInPallet < ActiveRecord::Migration[6.1]
  def change
    change_column :return_products, :issue_id, :bigint, null: true
    rename_column :pallet_shippings, :depth, :length
  end
end
