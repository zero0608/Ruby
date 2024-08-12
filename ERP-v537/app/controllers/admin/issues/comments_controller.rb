class Admin::Issues::CommentsController < Admin::CommentsController
  before_action :set_commentable
  private

    def set_commentable
      @commentable = Issue.find(params[:issue_id])
    end
end
