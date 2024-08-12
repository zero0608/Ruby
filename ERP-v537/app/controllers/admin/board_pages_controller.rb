class Admin::BoardPagesController < ApplicationController
  def new
    board_page = BoardPage.create(board_section_id: params[:board_section_id], position: BoardPage.where(board_section_id: params[:board_section_id]).count + 1)
    redirect_to edit_board_admin_board_sections_path(page_id: board_page.id)
  end

  def update
    board_page = BoardPage.find_by(id: params[:id])
    board_page.update(board_page_params)
    redirect_to edit_board_admin_board_sections_path(page_id: board_page.id)
  end

  private

  def board_page_params
    params.require(:board_page).permit(:name, :content, :tag, :board_section_id)
  end
end