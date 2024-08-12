class NotificationReflex < ApplicationReflex
  def read_all_notifications
    user = User.find(element.dataset[:user_id])
    notifications = user.notifications.where.not("params ->> 'content' = 'announcement'").where(clear_at: nil)
    notifications.update_all(read_at: Time.now)
  end

  def read_all_announcements
    user = User.find(element.dataset[:user_id])
    notifications = user.notifications.where("params ->> 'content' = 'announcement'").where(clear_at: nil)
    notifications.update_all(read_at: Time.now)
  end

  def clear_all_notifications
    user = User.find(element.dataset[:user_id])
    notifications = user.notifications.where.not("params ->> 'content' = 'announcement'")
    notifications.update_all(clear_at: Time.now, read_at: Time.now)
  end

  def clear_all_announcements
    user = User.find(element.dataset[:user_id])
    notifications = user.notifications.where("params ->> 'content' = 'announcement'")
    notifications.update_all(clear_at: Time.now, read_at: Time.now)
  end

  def clear_notification
    notification = Notification.find_by(id: element.dataset[:notification_id])
    notification.update(clear_at: Time.now, read_at: Time.now)
  end

  def clear_announcement
    notification = Notification.find_by(id: element.dataset[:notification_id])
    notification.update(clear_at: Time.now, read_at: Time.now)
  end
end