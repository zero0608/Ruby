class Admin::Orders::CommentsController < Admin::CommentsController
  before_action :set_commentable
  private

    def set_commentable
      @commentable = Order.find_by(name: params[:order_name])
    end
end
