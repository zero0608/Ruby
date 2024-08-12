class AddStageDateToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :deal_view_id, :integer
    add_column :deals, :stage_date, :json, default: {0=>nil, 1=>nil, 2=>nil, 3=>nil, 4=>nil}
  end
end
