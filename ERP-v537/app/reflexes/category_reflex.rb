# frozen_string_literal: true

class CategoryReflex < ApplicationReflex
  def build_sub_categories
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @category = Category.find_by(id: element.dataset[:category_id])
    @category.subcategories.create
  end

  private

  def category_params
    params.require(:category).permit(:title, subcategories_attributes: [:id, :title, :category_id])
  end
end