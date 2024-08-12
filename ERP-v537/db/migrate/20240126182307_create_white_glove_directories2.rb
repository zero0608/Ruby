class CreateWhiteGloveDirectories2 < ActiveRecord::Migration[6.1]
  def change
    create_table :white_glove_directories do |t|
      t.string :company_name
      t.string :store
      t.timestamps
    end

    add_reference :white_glove_addresses, :white_glove_directory, foreign_key: true
    add_reference :shipping_details, :white_glove_directory, foreign_key: true
  end
end