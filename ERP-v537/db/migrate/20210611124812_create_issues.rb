class CreateIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :issues do |t|
      t.string :ticket, :options => 'PRIMARY KEY'
      t.string :title
      t.string :description
      t.string :created_by
      t.string :assign_to
      t.references :order, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
