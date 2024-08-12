class Admin::UsersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:update, :change_password, :update_password, :verify_qrcode, :enable_2fa]
  before_action :find_user, only: [:edit, :update, :change_password, :update_password, :destroy, :verify_qrcode, :enable_2fa]

  def index
    if current_user.user_group.admin_view
      @users = User.eager_load([:user_group]).where(supplier_id: nil)
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    password = generate_password
    @user.password = password
    if @user.save
      UserMailer.send_password_to_user(password, @user).deliver!
      redirect_to admin_users_path, success: "User created successfully."
    else
      render 'new'
    end
  end

  def edit
    if current_user.user_group.admin_cru
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @user.update(user_params)
      if @user.otp_required_for_login && !@user.deactivate
        redirect_to verify_qrcode_admin_user_path(@user)
      else
        redirect_to root_path, success: "User updated successfully."
      end
      
    else
      render 'edit'
    end
  end

  def verify_qrcode
    @user.otp_secret = User.generate_otp_secret
    @user.save
    issuer = 'Eternity'
    label = "#{issuer}:#{@user.email}"
    @qr_code = RQRCode::QRCode.new([ {data: @user.otp_provisioning_uri(label, issuer: issuer), mode: :byte_8bit } ])
    @backup_codes = @user.generate_otp_backup_codes!
    UserMailer.with(recipient: @user, otp_backup_codes: @backup_codes).send_backup_codes.deliver_later
  end

  def change_password;end

  def update_password
    if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      redirect_to request.referrer, success: "Password updated successfully."
    else
      redirect_to request.referrer, warning: "Password failed to update."
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path
  end

  private

  def find_user
    @user = User.find_by(slug: params[:slug])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :user_group_id, :deactivate, :username, :employee_id, :otp_required_for_login,
    notification_setting: {})
  end

  def generate_password
    Devise.friendly_token.first(8)
  end
end
