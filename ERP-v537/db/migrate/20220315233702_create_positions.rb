class CreatePositions < ActiveRecord::Migration[6.1]
  def change
    create_table :positions do |t|
      t.references :department, foreign_key: true
      t.string :name
      t.boolean :is_manager

      t.timestamps
    end
  end
end
