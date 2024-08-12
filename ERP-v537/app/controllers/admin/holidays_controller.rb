class Admin::HolidaysController < ApplicationController
  def index
    if current_user.user_group.hr_view
    else
      render "dashboard/unauthorized"
    end
  end
end