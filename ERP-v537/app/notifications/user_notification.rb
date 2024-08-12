# To deliver this notification:
#
# UserNotification.with(post: @post).deliver_later(current_user)
# UserNotification.with(post: @post).deliver(current_user)
# require_relative 'app/notifications/user_notification'

class UserNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  deliver_by :action_cable, format: :format_for_action_cable
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :order, :issue, :user, :content, :container

  def format_for_action_cable
    {
      notification_id: self.record.id,
      data: ApplicationController.render( 
            partial: "includes/notifications",
            locals: { notification: self.record }
          )
    }
  end

  # def format_for_database
  #   {
  #     params: self.params.slice(:order, :issue, :user, :content),
  #     recipient: self.recipient,
  #     type: self.class,
  #   }
  # end

  # Define helper methods to make rendering easier.
  #
  def message
    t(".message")
  end
  #
  def url
    root_path
  end
end
