class CreateSubcategories < ActiveRecord::Migration[6.1]
  def change
    create_table :subcategories do |t|
      t.references :category, null: true, foreign_key: true
      t.text :name

      t.timestamps
    end
  end
end
