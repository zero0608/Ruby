class Admin::BoardSectionsController < ApplicationController
  def index
    if current_user.user_group.board_view
      if params[:page_id].present?
        @board_page = BoardPage.find_by(id: params[:page_id])
      else
        @board_page = nil
        BoardSection.where(main_board: nil).order(:position).each do |bs|
          BoardSection.where(main_board: bs.id).order(:position).each do |bss|
            if bss.board_pages.present?
              @board_page = bss.board_pages.first
              break
            end
          end
          if @board_page.present?
            break
          elsif bs.board_pages.present?
            @board_page = bs.board_pages.first
            break
          end
        end
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    BoardSection.create(name: params[:board_section][:name], position: BoardSection.where(main_board: nil).count + 1)
    redirect_to edit_board_admin_board_sections_path
  end

  def edit_board
    if current_user.user_group.board_cru
      if params[:page_id].present?
        @board_page = BoardPage.find_by(id: params[:page_id])
      else
        @board_page = nil
        BoardSection.where(main_board: nil).order(:position).each do |bs|
          BoardSection.where(main_board: bs.id).order(:position).each do |bss|
            if bss.board_pages.present?
              @board_page = bss.board_pages.first
              break
            end
          end
          if @board_page.present?
            break
          elsif bs.board_pages.present?
            @board_page = bs.board_pages.first
            break
          end
        end
      end

      @create_section = BoardSection.find_by(id: params[:create_section_id]) if params[:create_section_id].present?
      @delete_section = BoardSection.find_by(id: params[:delete_section_id]) if params[:delete_section_id].present?
    else
      render "dashboard/unauthorized"
    end
  end

  def new_sub_board
    board_section = BoardSection.create(name: params[:name], main_board: params[:section_id], position: BoardSection.where(main_board: params[:section_id]).count + 1)
    redirect_to edit_board_admin_board_sections_path
  end

  def delete_board
    board_section = BoardSection.find_by(id: params[:section_id])
    if params[:new_section_id].present?
      new_board_section = BoardSection.find_by(id: params[:new_section_id])
      board_section.board_pages.each do |bp|
        bp.update(board_section_id: new_board_section.id, position: new_board_section.board_pages.count + 1)
      end

      if board_section.main_board == nil && new_board_section.main_board == nil
        BoardSection.where(main_board: board_section.id).each do |bs|
          bs.update(main_board: new_board_section.id, position: BoardSection.where(main_board: board_section.id).count + 1)
        end
      
      elsif board_section.main_board == nil && new_board_section.main_board != nil
        BoardSection.where(main_board: board_section.id).each do |bs|
          bs.board_pages.each do |bp|
            bp.update(board_section_id: new_board_section.id, position: new_board_section.board_pages.count + 1)
          end
          BoardSection.find(bs.id).destroy
        end
      end
    end
    BoardSection.where(main_board: board_section.main_board).where("board_sections.position > ?", board_section.position).each do |bs|
      bs.update(position: bs.position - 1)
    end

    BoardSection.find(board_section.id).board_pages.destroy_all
    BoardSection.find(board_section.id).destroy

    redirect_to edit_board_admin_board_sections_path
  end
end