class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :showrooms do |t|
      t.string :name
      t.string :abbreviation
      t.string :store

      t.timestamps
    end

    create_table :appointments do |t|
      t.references :customer, foreign_key: true
      t.references :employee, foreign_key: true
      t.references :showroom, foreign_key: true
      t.date :appointment_date
      t.time :appointment_time
      t.integer :appointment_type
      t.string :notes

      t.timestamps
    end
    
    remove_column :employees, :sales_manager_permission, :boolean
    remove_column :employees, :sales_permission, :boolean

    add_column :employees, :sales_permission, :integer
    add_reference :employees, :showroom, foreign_key: true

    create_table :showroom_manage_permissions do |t|
      t.references :employee, foreign_key: true
      t.references :showroom, foreign_key: true
      t.boolean :permission, default: false
    end

    add_column :invoices, :lead_note, :string

    add_column :customer_billing_addresses, :first_name, :string
    add_column :customer_billing_addresses, :last_name, :string
    add_column :customer_billing_addresses, :phone, :string
    add_column :customer_billing_addresses, :email, :string
  end
end