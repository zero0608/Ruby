class AddFactoryToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :factory, :string
  end
end
