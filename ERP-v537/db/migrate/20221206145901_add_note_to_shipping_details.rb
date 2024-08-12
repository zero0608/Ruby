class AddNoteToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :note, :string
  end
end
