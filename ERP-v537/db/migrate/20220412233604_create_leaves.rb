class CreateLeaves < ActiveRecord::Migration[6.1]
  def change
    create_table :leaves do |t|
      t.references :employee, foreign_key: true
      t.string :leave_type
      t.date :start_date
      t.date :end_date
      t.float :duration
      t.string :status

      t.timestamps
    end
  end
end