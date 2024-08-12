class Admin::CommentsController < ApplicationController

  def index
  end

  def create
    ::Audited.store[:current_user] = current_user
    @comment = @commentable.comments.new comment_params
    @comment.user_id = current_user.id
    @comment.save
    
  end

  private

  def comment_params
    params.require(:comment).permit(:description, :tag_user_id)
  end
end
