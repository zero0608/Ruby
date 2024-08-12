class AddReminderDateToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :reminder_date, :date
  end
end
