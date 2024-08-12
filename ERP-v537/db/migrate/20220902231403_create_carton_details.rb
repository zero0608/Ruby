class CreateCartonDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :carton_details do |t|
      t.references :product, foreign_key: true
      t.string :length
      t.string :width
      t.string :height
      t.string :weight
      t.integer :index

      t.timestamps
    end

    drop_table :product_cartons
    add_reference :cartons, :carton_detail, foreign_key: true
    remove_column :cartons, :carton_length, :string
    remove_column :cartons, :width, :string
    remove_column :cartons, :height, :string
    remove_column :cartons, :weight, :string
  end
end
