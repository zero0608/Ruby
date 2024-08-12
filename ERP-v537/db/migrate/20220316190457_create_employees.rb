class CreateEmployees < ActiveRecord::Migration[6.1]
  def change
    create_table :employees do |t|
      t.references :department, foreign_key: true
      t.references :position, foreign_key: true
      t.references :manager, foreign_key: { to_table: :employees }
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.date :dob
      t.string :employment_type
      t.string :health_number
      t.string :emergency_contact
      t.string :emergency_number
      t.boolean :work_mon
      t.boolean :work_tue
      t.boolean :work_wed
      t.boolean :work_thu
      t.boolean :work_fri
      t.boolean :work_sat
      t.boolean :work_sun
      t.date :start_date
      t.date :exit_date
      t.boolean :voluntary_exit
      t.float :salary
      t.float :bonus
      t.integer :pto_days
      t.integer :personal_days
      t.integer :sick_days
      t.string :hr_notes

      t.timestamps
    end
  end
end