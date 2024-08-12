class CreateFactory < ActiveRecord::Migration[6.1]
  def change
    create_table :factories do |t|
      t.string :name

      t.timestamps
    end

    add_reference :products, :factory, foreign_key: true
  end
end
