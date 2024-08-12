class ChangePermissionToUserGroups < ActiveRecord::Migration[6.1]
  def change
    change_column_default :user_groups, :permission_us, "true"
    change_column_default :user_groups, :permission_ca, "true"
  end
end
