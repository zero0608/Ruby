class Admin::Containers::CommentsController < ApplicationController
  before_action :set_commentable
  private

    def set_commentable
      @commentable = Container.find(params[:container_id])
    end
end
