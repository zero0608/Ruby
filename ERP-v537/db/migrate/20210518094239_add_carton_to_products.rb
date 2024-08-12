class AddCartonToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :carton, :json
  end
end
