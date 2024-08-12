class BillingSectionReflex < ApplicationReflex
  include Pagy::Backend

  def filter_data
    if params[:action] == "review"
      current_store = element.dataset[:current_store]
      if element.dataset[:white_glove] == "true"
        directory_id = element.dataset[:truck_broker_id].to_i
        review_id = Array.new
        ReviewSection.where(store: current_store, responded: nil).where(white_glove: true).each do |review|
          if review.order_id.present?
            review_id.push(review.id) if review.shipping_detail&.white_glove_directory_id == directory_id
          elsif review.return_id.present?
            review_id.push(review.id) if review.return&.white_glove_directory_id == directory_id
          elsif review.consolidation_id.present?
            review_id.push(review.id) if review.consolidation.shipping_details.first&.white_glove_directory_id == directory_id
          end
        end
        @reviews = ReviewSection.where(id: review_id)
        @filter = "WGD"

      else
        truck_broker_id = element.dataset[:truck_broker_id].to_i
        review_id = Array.new
        ReviewSection.where(store: current_store, responded: nil).where(white_glove: false).each do |review|
          if review.order_id.present?
            review_id.push(review.id) if review.shipping_detail&.shipping_quotes&.find_by(selected: true)&.truck_broker_id == truck_broker_id
          elsif review.return_id.present?
            review_id.push(review.id) if review.return&.carrier&.truck_broker_id == truck_broker_id
          elsif review.consolidation_id.present?
            review_id.push(review.id) if review.consolidation.shipping_details.first&.shipping_quotes&.find_by(selected: true)&.truck_broker_id == truck_broker_id
          end
        end
        @reviews = ReviewSection.where(id: review_id)
      end

      assigns = {
        reviews: @reviews,
        filter: @filter,
        current_store: current_store
      }

      morph :nothing

      cable_ready
        .inner_html(selector: "#filter-review", html: render(partial: "filter_review", assigns: assigns))
        .push_state()
        .broadcast

    elsif params[:action] == "posting"
      current_store = element.dataset[:current_store]
      if element.dataset[:white_glove] == "true"
        directory_id = element.dataset[:truck_broker_id].to_i
        posting_id = Array.new
        PostingSection.where(store: current_store, responded: nil).where(white_glove: true).each do |posting|
          if posting.order_id.present?
            posting_id.push(posting.id) if posting.shipping_detail&.white_glove_directory_id == directory_id
          elsif posting.return_id.present?
            posting_id.push(posting.id) if posting.return&.white_glove_directory_id == directory_id
          elsif posting.consolidation_id.present?
            posting_id.push(posting.id) if posting.consolidation.shipping_details.first&.white_glove_directory_id == directory_id
          end
        end
        @postings = PostingSection.where(id: posting_id)
        @filter = "WGD"

      else
        truck_broker_id = element.dataset[:truck_broker_id].to_i
        posting_id = Array.new
        PostingSection.where(store: current_store, responded: nil).where(white_glove: false).each do |posting|
          if posting.order_id.present?
            posting_id.push(posting.id) if posting.shipping_detail&.shipping_quotes&.find_by(selected: true)&.truck_broker_id == truck_broker_id
          elsif posting.return_id.present?
            posting_id.push(posting.id) if posting.return&.carrier&.truck_broker_id == truck_broker_id
          elsif posting.consolidation_id.present?
            posting_id.push(posting.id) if posting.consolidation.shipping_details.first&.shipping_quotes&.find_by(selected: true)&.truck_broker_id == truck_broker_id
          end
        end
        @postings = PostingSection.where(id: posting_id)
      end

      assigns = {
        postings: @postings,
        filter: @filter,
        current_store: current_store
      }

      morph :nothing

      cable_ready
        .inner_html(selector: "#filter-posting", html: render(partial: "filter_posting", assigns: assigns))
        .push_state()
        .broadcast
    end
  end

  def filter_invoice
    if params[:action] == "posting"
      current_store = element.dataset[:current_store]
      invoice_number = element.dataset[:filter]
      @postings = PostingSection.where(store: current_store, responded: nil).eager_load(shipping_detail: [:invoice_for_billing, :invoice_for_wgd]).where("invoice_for_billings.invoice_number = ? OR invoice_for_wgds.invoice_number = ?", invoice_number, invoice_number)
      
      assigns = {
        postings: @postings,
        filter: @filter
      }

      # uri = URI.parse([request.base_url, request.path].join)
      # uri.query = assigns.except(:orders, :pagy).to_query

      morph :nothing

      cable_ready
        .inner_html(selector: "#filter-posting", html: render(partial: "filter_posting", assigns: assigns))
        .push_state()
        .broadcast
    end
  end

  def search_add_order
    @query = element[:value].strip
    @orders = Order.where("orders.name ILIKE ?", "%#{@query}%")
    @consolidations = Consolidation.where("consolidations.name ILIKE ?", "%#{@query}%")
    assigns = {
      orders: @orders,
      consolidations: @consolidations
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#search-add-order-results", html: render(partial: "add_orders", assigns: assigns))
      .push_state()
      .broadcast
  end

  def add_order
    order = Order.find_by(id: element.dataset[:id])
    order.shipping_details.each do |sd|
      if sd.status == "shipped"
        unless sd.review_sections.where(white_glove: true).present?
          if sd.white_glove_fee.present? && (sd.white_glove_fee.to_f > 0)
            review = ReviewSection.create(order_id: order.id, store: order.store, shipping_detail_id: sd.id, invoice_type: sd&.white_glove_directory&.company_name, white_glove: true)
            sd.create_invoice_for_wgd
          end
        end

        unless sd.review_sections.where(white_glove: false).present?
          if sd&.shipping_quotes&.find_by(selected: true) && !sd&.consolidation&.review_sections&.present?
            unless sd&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Local" || sd&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Factory to Customer" || sd&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Accurate"
              if sd.consolidation_id.present?
                unless sd.consolidation.review_sections.present?
                  review = ReviewSection.create(consolidation_id: sd.consolidation_id, store: order.store, invoice_type: sd&.shipping_quotes&.find_by(selected: true)&.carrier&.name, white_glove: false)
                  sd.consolidation.create_invoice_for_billing
                end
              else
                review = ReviewSection.create(order_id: order.id, store: order.store, shipping_detail_id: sd.id, invoice_type: sd&.shipping_quotes&.find_by(selected: true)&.carrier&.name, white_glove: false)
                sd.create_invoice_for_billing
              end
            end
          end
        end
      end
    end
  end

  def post
    current_store = element.dataset[:current_store]
    posting = PostingSection.find(element.dataset[:id])
    posting.update(posted: element.checked)
  end

  def record_post
    current_store = element.dataset[:current_store]
    record = RecordSection.find(element.dataset[:id])
    record.update(posted: element.checked)
  end

  def remove_review
    review = ReviewSection.find_by(id: element.dataset[:review_id])
    review.destroy
  end

  def review_search
    params[:query] = element[:value].strip
    update_review
  end

  def review_paginate
    params[:page] = element.dataset[:page].to_i
    update_review
  end

  def posting_search
    params[:query] = element[:value].strip
    update_posting
  end

  def posting_paginate
    params[:page] = element.dataset[:page].to_i
    update_posting
  end

  def record_search
    params[:query] = element[:value].strip
    update_record
  end

  def record_search_invoice
    params[:query] = element[:value].strip
    update_record_invoice
  end

  def record_paginate
    params[:page] = element.dataset[:page].to_i
    update_record
  end

  def dispute_consolidate_shipping
    shipping_detail = ShippingDetail.find_by(id: element.dataset[:shipping_id])
    consolidation = Consolidation.find_by(id: element.dataset[:consolidation_id])
    shipping_detail.update(consolidation_id: nil)

    if shipping_detail.white_glove_fee.present? && (shipping_detail.white_glove_fee.to_f > 0) && !(shipping_detail.review_sections.present?)
      @review = ReviewSection.create(order_id: shipping_detail.order.id, store: shipping_detail.order.store, shipping_detail_id: shipping_detail.id, invoice_type: shipping_detail&.white_glove_directory&.company_name, white_glove: true, responded: true)

      shipping_detail.create_invoice_for_wgd
      
      @posting = PostingSection.create(order_id: @review.order_id, store: @review.store, shipping_detail_id: @review.shipping_detail_id, invoice_type: @review.invoice_type, return_id: @review.return_id, consolidation_id: @review.consolidation_id, status: "paid", white_glove: @review.white_glove)
    end
    if shipping_detail.carrier.present? && !(shipping_detail.review_sections.present? || shipping_detail&.consolidation&.review_sections&.present?)
      unless shipping_detail&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Local" || shipping_detail&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Factory to Customer" || shipping_detail&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Accurate"
        @review = ReviewSection.create(order_id: shipping_detail.order.id, store: shipping_detail.order.store, shipping_detail_id: shipping_detail.id, invoice_type: shipping_detail.carrier.name, white_glove: false)
        
        shipping_detail.create_invoice_for_billing
      
        @posting = PostingSection.create(order_id: @review.order_id, store: @review.store, shipping_detail_id: @review.shipping_detail_id, invoice_type: @review.invoice_type, return_id: @review.return_id, consolidation_id: @review.consolidation_id, status: "dispute", white_glove: @review.white_glove)
      end
    end
  end

  private

  def update_review
    @query = params[:query]
    current_store = element.dataset[:current_store]
    reviews = ReviewSection.where(store: current_store, responded: nil, white_glove: false)
    reviews = reviews.eager_load(:order, :consolidation, :return).where("(orders.name ILIKE ?) OR (consolidations.name ILIKE ?) OR (returns.name ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?
    page_count = (reviews.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @reviews = pagy(reviews, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      reviews: @reviews,
      current_store: current_store
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#filter-review", html: render(partial: "filter_review", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_posting
    @query = params[:query]
    postings = PostingSection.where(store: element.dataset[:current_store], responded: nil)
    postings = postings.eager_load(:order, :consolidation, :return, shipping_detail: [:invoice_for_billing, :invoice_for_wgd]).where("orders.name ILIKE ? OR consolidations.name ILIKE ? OR returns.name ILIKE ? OR invoice_for_billings.invoice_number LIKE ? OR invoice_for_wgds.invoice_number LIKE ?", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?

    page_count = (postings.count / Pagy::VARS[:items].to_f).ceil

    @postings = postings

    assigns = {
      postings: @postings
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#filter-posting", html: render(partial: "filter_posting", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_record
    @query = params[:query]
    records = RecordSection.where(store: element.dataset[:current_store], responded: nil)
    records = records.eager_load(:order, :consolidation, :return).where("orders.name ILIKE ? OR consolidations.name ILIKE ? OR returns.name ILIKE ?", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?

    page_count = (records.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @records = pagy(records, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      records: @records
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#filter-record", html: render(partial: "filter_record", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_record_invoice
    @query = params[:query]
    records = RecordSection.where(store: element.dataset[:current_store], responded: nil)
    records = records.eager_load(shipping_detail: [:invoice_for_billing, :invoice_for_wgd]).where("invoice_for_billings.invoice_number LIKE ? OR invoice_for_wgds.invoice_number LIKE ?", "%#{@query}%", "%#{@query}%") if @query.present?

    page_count = (records.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @records = pagy(records, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      records: @records
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#filter-record", html: render(partial: "filter_record", assigns: assigns))
      .push_state()
      .broadcast
  end
end