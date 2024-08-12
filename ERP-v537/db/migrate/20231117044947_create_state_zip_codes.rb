class CreateStateZipCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :state_zip_codes do |t|
      t.references :tax_rate, foreign_key: true
      t.string :zip_code
      t.boolean :remote

      t.timestamps
    end
  end
end
