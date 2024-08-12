class AddClearSwatchToLIneItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :clear_swatch, :boolean
  end
end
