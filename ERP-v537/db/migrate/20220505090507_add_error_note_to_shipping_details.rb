class AddErrorNoteToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :error_notes, :string
  end
end
