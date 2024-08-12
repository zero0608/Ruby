class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.references :product, null: true, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
