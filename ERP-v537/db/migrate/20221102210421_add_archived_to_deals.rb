class AddArchivedToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :archived, :boolean
  end
end
