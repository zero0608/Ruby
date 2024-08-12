class CreateWarehousePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouse_permissions do |t|
      t.references :user_group, foreign_key: true
      t.references :warehouse, foreign_key: true
      t.boolean :permission, default: false

      t.timestamps
    end
  end
end
