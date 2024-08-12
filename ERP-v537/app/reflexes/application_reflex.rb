# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  include Pagy::Backend

  def current_store
    session[:store] = element.dataset[:store_type] if element.dataset[:store_type].present?
    session[:store] = 'us' if session[:store].nil?
    session[:store]
  end

  def order
    params[:order_by] = element.dataset["column-name"]
    params[:direction] = element.dataset["direction"]
    update_client
  end
    
end
