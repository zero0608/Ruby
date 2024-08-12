class UserMailer < ApplicationMailer

  def send_password_to_user(password, user)
    @password = password
    @user = user
    mail(to: @user.email, from: "admin@eternity.com", reply_to: 'admin@eternity.com', subject: 'New Account')
  end

  def send_backup_codes
    @user = params[:recipient]
    @otp_backup_codes = params[:otp_backup_codes]
    mail(to: @user.email, subject: 'OTP Backup Codes')
  end
end
