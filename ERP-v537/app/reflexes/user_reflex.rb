# frozen_string_literal: true

class UserReflex < ApplicationReflex

  def submit
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @supplier = Supplier.find_by(slug: element.dataset[:supplier_slug])
    @user = @supplier.users.new(user_params)
    password = generate_password
    @user.password = password
    @user.user_group = UserGroup.first
    if @user.save
      UserMailer.send_password_to_user(password, @user).deliver!     
    end
  end 

  def user_submit
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @warehouse = Warehouse.find(element.dataset[:warehouse_id])
    @user = @warehouse.users.new(user_params)
    password = generate_password
    @user.password = password
    @user.user_group = UserGroup.first
    if @user.save
      UserMailer.send_password_to_user(password, @user).deliver!     
    end
  end

  def notification_setting
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @user = User.find(element.dataset[:user_id])
    @user.update(user_params)
  end

  def disabled_2fa
    user = User.find(element.dataset[:value])
    user.update(otp_required_for_login: false)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :user_group_id, :deactivate, notification_setting: {})
  end

  def generate_password
    Devise.friendly_token.first(8)
  end

end
