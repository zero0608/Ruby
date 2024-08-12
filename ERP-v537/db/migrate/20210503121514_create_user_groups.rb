class CreateUserGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :user_groups do |t|
      t.string :name
      t.string :permissions
      t.string :slug

      t.timestamps
    end
  end
end
