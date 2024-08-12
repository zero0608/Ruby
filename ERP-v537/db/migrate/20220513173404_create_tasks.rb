class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :owner, foreign_key: { to_table: :users }
      t.date :due_date
      t.integer :priority
      t.string :description
      t.boolean :completed

      t.timestamps
    end
  end
end
