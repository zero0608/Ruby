class ProductLocationReflex < ApplicationReflex
  def update
    if element.dataset[:type] == "rack"
      ProductLocation.find_by(id: element.dataset[:id]).update(rack: element[:value])
    elsif element.dataset[:type] == "level"
      ProductLocation.find_by(id: element.dataset[:id]).update(level: element[:value])
    elsif element.dataset[:type] == "bin"
      ProductLocation.find_by(id: element.dataset[:id]).update(bin: element[:value])
    end
  end
  
  def delete
    location = ProductLocation.find_by(id: element.dataset[:id])
    if location.carton_locations.exists?
      flash[:error] = "Cartons are assigned to this location."
    else
      ProductLocation.find_by(id: element.dataset[:id]).destroy
    end
  end
end