class AddOtpVerifyDateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_otp_verify_date, :datetime
  end
end
