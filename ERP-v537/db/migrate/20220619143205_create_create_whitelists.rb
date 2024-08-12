class CreateCreateWhitelists < ActiveRecord::Migration[6.1]
  def change
    create_table :create_whitelists do |t|
      t.string :ip_address
      t.string :name

      t.timestamps
    end
  end
end
