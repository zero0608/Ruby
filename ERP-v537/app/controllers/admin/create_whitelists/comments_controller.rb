class Admin::CreateWhitelists::CommentsController < Admin::CommentsController
  before_action :set_commentable
  private

    def set_commentable
      @commentable = CreateWhitelist.find(params[:create_whitelist_id])
    end
end
