class AddEditableToShippingLines < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_lines, :editable, :boolean, default: false
  end
end
