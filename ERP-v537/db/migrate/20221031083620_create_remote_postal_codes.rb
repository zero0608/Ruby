class CreateRemotePostalCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :remote_postal_codes do |t|
      t.string :postal_code
      t.string :store

      t.timestamps
    end
  end
end
