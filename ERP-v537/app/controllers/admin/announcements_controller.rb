class Admin::AnnouncementsController < ApplicationController
  def index
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    if @announcement.save
      UserNotification.with(order: 'nil', issue: 'nil', user: current_user, content: "announcement", description: @announcement.description, topic: @announcement.topic, container: 'nil').deliver(User.where(deactivate: [false, nil], supplier_id: nil))
      redirect_back fallback_location: root_path
    end
  end

  private

  def announcement_params
    params.require(:announcement).permit(:user_id, :description, :topic)
  end
end