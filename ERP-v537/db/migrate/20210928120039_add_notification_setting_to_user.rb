class AddNotificationSettingToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :notification_setting, :json, default: {}, null: true
  end
end
