class AddSlugToSupplier < ActiveRecord::Migration[6.1]
  def change
    add_column :suppliers, :slug, :string
  end
end
