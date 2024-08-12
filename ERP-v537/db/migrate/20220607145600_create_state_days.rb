class CreateStateDays < ActiveRecord::Migration[6.1]
  def change
    create_table :state_days do |t|
      t.string :state
      t.string :start_days
      t.string :end_days

      t.timestamps
    end
  end
end
