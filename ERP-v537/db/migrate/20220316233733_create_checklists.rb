class CreateChecklists < ActiveRecord::Migration[6.1]
  def change
    create_table :checklists do |t|
      t.references :employee, foreign_key: true
      t.string :description
      t.string :list_type
      t.boolean :is_checked
      t.boolean :is_default

      t.timestamps
    end
  end
end
