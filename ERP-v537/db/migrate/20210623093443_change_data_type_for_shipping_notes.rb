class ChangeDataTypeForShippingNotes < ActiveRecord::Migration[6.1]
  def change
    change_column :shipping_details, :shipping_notes, :text
  end
end
