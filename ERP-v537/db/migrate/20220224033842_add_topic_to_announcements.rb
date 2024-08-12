class AddTopicToAnnouncements < ActiveRecord::Migration[6.1]
  def change
    add_column :announcements, :topic, :string
  end
end
