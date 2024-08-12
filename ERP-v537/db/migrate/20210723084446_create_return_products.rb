class CreateReturnProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :return_products do |t|
      t.references :order, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.references :line_item, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
