class CreateCartons < ActiveRecord::Migration[6.1]
  def change
    create_table :cartons do |t|
      t.references :product, null: false, foreign_key: true
      t.string :height
      t.string :width
      t.string :weight
      t.string :carton_length

      t.timestamps
    end
  end
end
