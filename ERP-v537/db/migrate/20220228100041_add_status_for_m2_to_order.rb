class AddStatusForM2ToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :status_for_M2, :integer
    add_column :orders, :sent_mail, :integer
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
