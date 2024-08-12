class AddTaXLinesToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :tax_lines, :json
  end
end
