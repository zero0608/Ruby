class BoardSectionReflex < ApplicationReflex
  def submit
    BoardSection.create(board_section_params)
  end

  def delete_page
    board_page = BoardPage.find_by(id: element.dataset[:page_id])
    BoardPage.where(board_section_id: board_page.board_section_id).where("board_pages.position > ?", board_page.position).each do |bp|
      bp.update(position: bp.position - 1)
    end
    board_page.destroy
  end

  def search
    params[:query] = element[:value].strip
    @query = params[:query]
    @board_pages = BoardPage.where("board_pages.tag @> ARRAY[?]::varchar[] OR board_pages.name ILIKE ?", @query, "%#{@query}%")

    assigns = {
      query: @query,
      board_pages: @board_pages
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#jstree-default", html: render(partial: "search_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def increase_position
    if element.dataset[:type] == "section"
      board_section = BoardSection.find_by(id: element.dataset[:id])
      position = board_section.position
      board_section_2 = BoardSection.find_by(main_board: board_section.main_board, position: (board_section.position - 1))
      position_2 = board_section_2.position
      board_section.update(position: position_2)
      board_section_2.update(position: position)
    elsif element.dataset[:type] == "page"
      board_page = BoardPage.find_by(id: element.dataset[:id])
      position = board_page.position
      board_page_2 = BoardPage.find_by(board_section_id: board_page.board_section_id, position: (board_page.position - 1))
      position_2 = board_page_2.position
      board_page.update(position: position_2)
      board_page_2.update(position: position)
    end
  end

  def decrease_position
    if element.dataset[:type] == "section"
      board_section = BoardSection.find_by(id: element.dataset[:id])
      position = board_section.position
      board_section_2 = BoardSection.find_by(main_board: board_section.main_board, position: (board_section.position + 1))
      position_2 = board_section_2.position
      board_section.update(position: position_2)
      board_section_2.update(position: position)
    elsif element.dataset[:type] == "page"
      board_page = BoardPage.find_by(id: element.dataset[:id])
      position = board_page.position
      board_page_2 = BoardPage.find_by(board_section_id: board_page.board_section_id, position: (board_page.position + 1))
      position_2 = board_page_2.position
      board_page.update(position: position_2) 
      board_page_2.update(position: position)
    end
  end

  def change_store1
    if element.dataset[:store] == "us"
      @store1 = "canada"
    else
      @store1 = "us"
    end
  end

  def change_date1
    @date1 = element.value.to_date
  end

  def change_store2
    if element.dataset[:store] == "us"
      @store2 = "canada"
    else
      @store2 = "us"
    end
  end

  def change_store3
    if element.value == "EMUS"
      @store3 = "us"
    else
      @store3 = "canada"
    end
  end

  def change_store4
    if element.value == "EMUS"
      @store4 = "us"
    else
      @store4 = "canada"
    end
  end

  private

  def board_section_params
    params.require(:board_section).permit(:name)
  end
end