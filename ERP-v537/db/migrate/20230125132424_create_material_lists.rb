class CreateMaterialLists < ActiveRecord::Migration[6.1]
  def change
    create_table :material_lists do |t|
      t.string :material_name

      t.timestamps
    end
  end
end
