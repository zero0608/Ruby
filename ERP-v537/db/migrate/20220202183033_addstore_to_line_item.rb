class AddstoreToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :store, :string
  end
end
