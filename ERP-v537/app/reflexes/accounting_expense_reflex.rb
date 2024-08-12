# frozen_string_literal: true

class AccountingExpenseReflex < ApplicationReflex

  def build_categories
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    ExpenseType.find_by(id: element.dataset[:type_id]).expense_categories.create
  end

  def build_sub_categories
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    ExpenseCategory.find_by(id: element.dataset[:category_id]).expense_subcategories.create
  end

  def build_payment_relation
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    ExpenseSubcategory.find_by(id: element.dataset[:subcategory_id]).expense_payment_relations.create
  end

  def update_category
    @expense_type = ExpenseType.find(element.dataset[:type_id])
    @expense_type.update(expense_type_params)
  end

  def update_post
    @expense_posting = ExpensePosting.find(element.dataset[:id])
    @expense_posting.update(posting: element.checked)
  end

  def filter_data
    if params[:action] == "expense_posting"
      @postings = ExpensePosting.where(status: "posting").eager_load(:expense).where(expense: { expense_type_id: element.dataset[:filter]})

      assigns = {
        postings: @postings
      }

      morph :nothing

      cable_ready
        .inner_html(selector: "#filter-posting", html: render(partial: "posting", assigns: assigns))
        .push_state()
        .broadcast

    elsif params[:action] == "expense_record"
      @postings = ExpensePosting.where(status: "record").eager_load(:expense).where(expense: { expense_type_id: element.dataset[:filter]})

      assigns = {
        postings: @postings
      }
      
      morph :nothing

      cable_ready
        .inner_html(selector: "#filter-record", html: render(partial: "record", assigns: assigns))
        .push_state()
        .broadcast
    end
  end

  def update_payment_method
    @payment_method = ExpensePaymentMethod.find_by(id: element.dataset[:payment_method_id])
    @payment_method.update(expense_payment_method_params)
    if @payment_method.deactivate
      ExpensePaymentRelation.where(expense_payment_method_id: @payment_method.id).destroy_all
    end
  end

  def link_payment_method
    if element.checked
      @payment_relation = ExpensePaymentRelation.find_by(expense_subcategory_id: element.dataset[:subcategory_id], expense_payment_method_id: nil)
      if @payment_relation.present?
        @payment_relation.update(expense_payment_method_id: element.dataset[:payment_method_id])
      else
        ExpensePaymentRelation.create(expense_subcategory_id: element.dataset[:subcategory_id], expense_payment_method_id: element.dataset[:payment_method_id])
      end
    else
      ExpensePaymentRelation.where(expense_subcategory_id: element.dataset[:subcategory_id], expense_payment_method_id: element.dataset[:payment_method_id]).destroy_all
    end
  end

  private

  def expense_type_params
    params.require(:expense_type).permit(:title, :id, :store, expense_categories_attributes: [:id, :title, expense_subcategories_attributes: [:id, :title, expense_payment_relations_attributes: [:id, :expense_payment_method_id]]])
  end
  
  def expense_payment_method_params
    params.require(:expense_payment_method).permit(:id, :title, :company_card, :deactivate)
  end
end