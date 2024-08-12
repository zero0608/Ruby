class CreateHolidays < ActiveRecord::Migration[6.1]
  def change
    create_table :holidays do |t|
      t.string :name
      t.date :date

      t.timestamps
    end
  end
end
