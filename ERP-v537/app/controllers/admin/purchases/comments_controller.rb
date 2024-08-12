class Admin::Purchases::CommentsController < Admin::CommentsController
  before_action :set_commentable
  private

    def set_commentable
      @commentable = Purchase.find_by(id: params[:purchase_id])
    end
end
