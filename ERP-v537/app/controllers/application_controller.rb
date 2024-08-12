class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  layout :get_layout

  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :danger, :info, :warning, :success

  before_action :fetch_notifications, :set_store, :set_showroom, :update_announcements, :task_reminder, :pending_payment_notifications, if: :current_user
  helper_method :current_store, :current_showroom

  # US_SHARED_SECRET = Rails.application.credentials.shopify[:us_store][:webhook_secret].freeze

  # CANADA_SHARED_SECRET = Rails.application.credentials.shopify[:canada_store][:webhook_secret].freeze
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:warning] = exception.message
    render "dashboard/unauthorized"
  end

  def set_store
    if params[:store].present?
      session[:store] = params[:store]
    end
    session[:store] = 'us' if session[:store].nil?
    session[:store]
  end

  def set_showroom
    if params[:showroom_id].present?
      session[:showroom] = Showroom.find_by(id: params[:showroom_id])
      session[:store] = Showroom.find_by(id: params[:showroom_id]).store
    end
    if session[:showroom].nil?
      if current_user&.employee&.sales_permission == "sales"
        session[:showroom] = current_user.employee.showroom
        session[:store] = current_user.employee.showroom.store
      elsif current_user&.employee&.sales_permission == "manager"
        session[:showroom] = current_user.employee.showroom_manage_permissions.first.showroom
        session[:store] = current_user.employee.showroom_manage_permissions.first.showroom.store
      end
    end
    session[:showroom]
  end

  def current_store
    store = session[:store]
    @current_store ||= store
  end

  def current_showroom
    showroom = session[:showroom]
    @current_showroom ||= showroom
  end

  def my_ip
    @ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    @ip.ip_address if @ip
  end

  protected
  
  def get_layout
    if user_signed_in?
      'admin'
    else
      'application'
    end
  end

  private

  def verify_ip_address
    #request.env['REMOTE_ADDR']
    #request.remote_ip
    # logger.info request.remote_ip
    # logger.info request.env["HTTP_X_FORWARDED_FOR"]
    # logger.info request.remote_addr
    # logger.info request.env['REMOTE_ADDR']
    head :unauthorized if CreateWhitelist.where(status: :enable).find_by(ip_address: request.remote_ip).nil?
  end

  def webhook_verified?
    begin
      decrypted = decrypt bearer_token
      if ActiveSupport::SecurityUtils.secure_compare(Rails.application.credentials.magento[:us][:us_token], decrypted)
        return true
      elsif ActiveSupport::SecurityUtils.secure_compare(Rails.application.credentials.magento[:canada][:canada_token], decrypted)
        return true
      end
    rescue => e
      puts "\n\n\n\n\n #{e.message}"
    end
  end

  def store_country
    begin
      decrypted = decrypt bearer_token
      if ActiveSupport::SecurityUtils.secure_compare(Rails.application.credentials.magento[:us][:us_token], decrypted)
        return 'us'
      elsif ActiveSupport::SecurityUtils.secure_compare(Rails.application.credentials.magento[:canada][:canada_token], decrypted)
        return 'canada'
      end
    rescue => e
      puts "\n\n\n\n\n #{e.message}"
    end
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def authenticated_user
    if current_user
      current_user
    else
      'Shopify'
    end     
  end

  def encrypt text
    text = text.to_s unless text.is_a? String
    len   = ActiveSupport::MessageEncryptor.key_len
    salt  = SecureRandom.hex len
    key   = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key salt, len
    crypt = ActiveSupport::MessageEncryptor.new key
    encrypted_data = crypt.encrypt_and_sign text
    "#{salt}$$#{encrypted_data}"
  end

  def decrypt text
    salt, data = text.split "$$"
    len   = ActiveSupport::MessageEncryptor.key_len
    key   = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key salt, len
    crypt = ActiveSupport::MessageEncryptor.new key
    crypt.decrypt_and_verify data
  end

  def fetch_notifications
    @notifications = current_user.notifications.where.not("params ->> 'content' = 'announcement'").where(clear_at: nil).newest_first
  end
  
  def update_announcements
    Announcement.all.each do |a|
      if (Date.today - a.created_at.to_date).to_i > 31
        a.destroy
      end
    end
  end

  def task_reminder
    Task.where(owner_id: current_user.id).where.not(status: :completed).where("reminder_date <= ?", Date.today).each do |task|
      unless Notification.where("params->> 'content' = 'task_reminder'").where("params ->> 'task_id' = '?'", task.id).present?
        UserNotification.with(order: 'nil', issue: 'nil', container: "ni", user: current_user, content: "task_reminder", message: task.title, task_id: task.id).deliver(current_user)
      end
    end
  end

  def pending_payment_notifications
    ::Audited.store[:current_user] = current_user
    Order.where(status: :pending_payment, pending_payment_notification: [0, nil]).where("orders.created_at < ?", Date.today - 5.days).each do |order|
      if order.update(pending_payment_notification: 1)
        UserNotification.with(order: order, issue: 'nil', user: current_user, content: "pending_payment", container: 'nil').deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'pending_payment' = ?", '1'))
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end
end
