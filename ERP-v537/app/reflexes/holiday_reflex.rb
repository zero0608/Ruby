class HolidayReflex < ApplicationReflex
  def create
    Holiday.create()
  end

  def update
    h = Holiday.find_by(id: element.dataset[:id])
    if element.dataset[:type] == "name"
      h.update(name: element[:value])
    else
      h.update(date: element[:value])
    end
  end

  def delete
    Holiday.find_by(id: element.dataset[:id]).destroy
  end
end