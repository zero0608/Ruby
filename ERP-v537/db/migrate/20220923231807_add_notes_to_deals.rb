class AddNotesToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :notes_title, :string
    add_column :deals, :notes, :string
  end
end
