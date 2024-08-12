class CreateWhiteGloveDirectories < ActiveRecord::Migration[6.1]
  def change
    create_table :white_glove_directories do |t|
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province
      t.string :country
      t.string :zip
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
