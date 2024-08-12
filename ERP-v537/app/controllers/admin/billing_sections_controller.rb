class Admin::BillingSectionsController < ApplicationController
  include Pagy::Backend
  require "pagy/extras/items"

  skip_before_action :verify_authenticity_token, only: [:upload_doc]

  def index
  end

  def upload_doc
    if params[:invoice_white_glove].present? && params[:invoice_white_glove] == "true"
      if params[:shipping_detail_id].present?
        @invoice = params[:invoice_id].present? ? InvoiceForWgd.find(params[:invoice_id]) : ShippingDetail.find(params[:shipping_detail_id]).build_invoice_for_wgd
      elsif params[:return_id].present?
        @invoice = params[:invoice_id].present? ? InvoiceForWgd.find(params[:invoice_id]) : Return.find(params[:return_id]).build_invoice_for_wgd
      elsif params[:consolidation_id].present?
        @invoice = params[:invoice_id].present? ? InvoiceForWgd.find(params[:invoice_id]) : Consolidation.find(params[:consolidation_id]).build_invoice_for_wgd
      end
      @invoice.update(invoice_wgd_params) if params[:invoice].present?

    else
      if params[:shipping_detail_id].present?
        @invoice = params[:invoice_id].present? ? InvoiceForBilling.find(params[:invoice_id]) : ShippingDetail.find(params[:shipping_detail_id]).build_invoice_for_billing
      elsif params[:return_id].present?
        @invoice = params[:invoice_id].present? ? InvoiceForBilling.find(params[:invoice_id]) : Return.find(params[:return_id]).build_invoice_for_billing
      elsif params[:consolidation_id].present?
        @invoice = params[:invoice_id].present? ? InvoiceForBilling.find(params[:invoice_id]) : Consolidation.find(params[:consolidation_id]).build_invoice_for_billing
      end
      @invoice.update(invoice_params) if params[:invoice].present?
    end

    case params[:section]
      when "review"
        redirect_to review_admin_billing_sections_path
      when "record"
        redirect_to records_admin_billing_sections_path
      when "posting"
        redirect_to posting_admin_billing_sections_path
    end
  end
  
  def review
    if params[:result].present?
      @review = ReviewSection.find(params[:review_id])
      if params[:result] == 'pay'
        @posting = PostingSection.create(order_id: @review.order_id, store: @review.store, shipping_detail_id: @review.shipping_detail_id, invoice_type: @review.invoice_type, return_id: @review.return_id, consolidation_id: @review.consolidation_id, status: "paid", white_glove: @review.white_glove)
        @posting.update(dispute_pay_reason: params[:dispute_pay_reason]) if params[:dispute_pay_reason].present?
        @review.update(responded: true)
        if @review.order_id.present?
          @review.order.comments.create(description: "Shipping invoice reviewed and approved for payment.", commentable_id: @review.order_id, commentable_type: "Order")
        elsif @review.return_id.present?
          @review.return.comments.create(description: "Shipping invoice reviewed and approved for payment.", commentable_id: @review.return_id, commentable_type: "Return")
        elsif @review.consolidation_id.present?
          @review.consolidation.comments.create(description: "Shipping invoice reviewed and approved for payment.", commentable_id: @review.consolidation_id, commentable_type: "Consolidation")
        end
      elsif params[:result] == "do_not_pay"
        @posting = PostingSection.create(order_id: @review.order_id, store: @review.store, shipping_detail_id: @review.shipping_detail_id, invoice_type: @review.invoice_type, return_id: @review.return_id, consolidation_id: @review.consolidation_id, status: "dispute", white_glove: @review.white_glove)
        @posting.update(dispute_not_paid_reason: params[:dispute_not_paid_reason]) if params[:dispute_not_paid_reason].present?
        @review.update(responded: true)
        if @review.order_id.present?
          @review.order.comments.create(description: "Shipping invoice reviewed and dispute not paid.", commentable_id: @review.order_id, commentable_type: "Order")
        elsif @review.return_id.present?
          @review.return.comments.create(description: "Shipping invoice reviewed and dispute not paid.", commentable_id: @review.return_id, commentable_type: "Return")
        elsif @review.consolidation_id.present?
          @review.consolidation.comments.create(description: "Shipping invoice reviewed and dispute not paid.", commentable_id: @review.consolidation_id, commentable_type: "Consolidation")
        end
      end
      redirect_to review_admin_billing_sections_path

    else
      @pagy, @reviews = pagy(ReviewSection.where(store: current_store, responded: nil, white_glove: false), items_param: :per_page, max_items: 100)
      @selected_review = ReviewSection.find_by(id: params[:selected_review]) if params[:selected_review].present?
      @filter ||= nil
    end
  end

  def posting
    if params[:result].present?
      @posting = PostingSection.find(params[:posting_id])
      if params[:result] == "posted"
        @record = RecordSection.create(order_id: @posting.order_id, store: @posting.store, shipping_detail_id: @posting.shipping_detail_id, invoice_type: @posting.invoice_type, return_id: @posting.return_id, consolidation_id: @posting.consolidation_id, status: @posting.status, white_glove: @posting.white_glove)
        @posting.update(responded: true)
        if @posting.order_id.present?
          @posting.order.comments.create(description: "Shipping invoice posted for payment.", commentable_id: @posting.order_id, commentable_type: "Order")
        elsif @posting.return_id.present?
          @posting.return.comments.create(description: "Shipping invoice posted for payment.", commentable_id: @posting.return_id, commentable_type: "Return")
        elsif @posting.consolidation_id.present?
          @posting.consolidation.comments.create(description: "Shipping invoice posted for payment.", commentable_id: @posting.consolidation_id, commentable_type: "Consolidation")
        end

      elsif params[:result] == "undo"
        @review = ReviewSection.find_by(order_id: @posting.order_id, store: @posting.store, shipping_detail_id: @posting.shipping_detail_id, responded: true, invoice_type: @posting.invoice_type, return_id: @posting.return_id, consolidation_id: @posting.consolidation_id, white_glove: @posting.white_glove)
        if @review.present?
          @review.update(reason: nil, amount: nil, responded: nil)
          @posting.destroy
        end
      end

      redirect_to posting_admin_billing_sections_path

    elsif params[:dispute].present?
      posting_id = params[:posting_ids].split(",").uniq
      if params[:dispute] == "pay"
        posting_id.each do |id|
          posting = PostingSection.find(id)
          posting.update(dispute_pay_reason: params[:reason])
          record = RecordSection.create(order_id: posting.order_id, store: posting.store, shipping_detail_id: posting.shipping_detail_id, posted: posting.posted, status: "paid", invoice_type: posting.invoice_type, return_id: posting.return_id, consolidation_id: posting.consolidation_id, white_glove: posting.white_glove)
          posting.update(responded: true, status: "paid")
          if posting.order_id.present?
            posting.order.comments.create(description: "Shipping invoice dispute pay approved, reason: #{posting.dispute_pay_reason}", commentable_id: posting.order_id, commentable_type: "Order")
          elsif posting.return_id.present?
            posting.return.comments.create(description: "Shipping invoice dispute pay approved, reason: #{posting.dispute_pay_reason}", commentable_id: posting.return_id, commentable_type: "Return")
          elsif posting.consolidation_id.present?
            posting.consolidation.comments.create(description: "Shipping invoice dispute pay approved, reason: #{posting.dispute_pay_reason}", commentable_id: posting.consolidation_id, commentable_type: "Consolidation")
          end
        end

      elsif params[:dispute] == "not pay"
        posting_id.each do |id|
          posting = PostingSection.find(id)
          posting.update(dispute_not_paid_reason: params[:reason])
          record = RecordSection.create(order_id: posting.order_id, store: posting.store, shipping_detail_id: posting.shipping_detail_id, posted: posting.posted, status: "dispute", invoice_type: posting.invoice_type, return_id: posting.return_id, consolidation_id: posting.consolidation_id, white_glove: posting.white_glove)
          posting.update(responded: true, status: "dispute")
          if posting.order_id.present?
            posting.order.comments.create(description: "Shipping invoice dispute not paid, reason: #{posting.dispute_not_paid_reason}", commentable_id: posting.order_id, commentable_type: "Order")
          elsif posting.return_id.present?
            posting.return.comments.create(description: "Shipping invoice dispute not paid, reaseon: #{posting.dispute_not_paid_reason}", commentable_id: posting.return_id, commentable_type: "Return")
          elsif posting.consolidation_id.present?
            posting.consolidation.comments.create(description: "Shipping invoice dispute not paid, reaseon: #{posting.dispute_not_paid_reason}", commentable_id: posting.consolidation_id, commentable_type: "Consolidation")
          end
        end
      end
      redirect_to posting_admin_billing_sections_path
    else
      @postings = PostingSection.where(store: current_store, responded: nil)
      @filter ||= nil
    end

    if params[:posting_ids].present?
      @selected_postings = PostingSection.where(id: params[:posting_ids].split(','))
      @brokers = Array.new
      @selected_postings.each do |posting|
        if posting.order_id.present?
          @brokers.push(posting.shipping_detail&.shipping_quotes&.find_by(selected: true)&.truck_broker_id)
        elsif posting.return_id.present?
          @brokers.push(posting.return&.carrier&.truck_broker_id)
        elsif posting.consolidation_id.present?
          @brokers.push(posting.consolidation.shipping_details.first&.shipping_quotes&.find_by(selected: true)&.truck_broker_id)
        end
      end
    end
  end

  def posting_all
    @postings = PostingSection.where(id: params[:posting_ids].split(",").uniq)
    @postings.each do |posting|
      record = RecordSection.create(order_id: posting.order_id, store: posting.store, shipping_detail_id: posting.shipping_detail_id, invoice_type: posting.invoice_type, return_id: posting.return_id, consolidation_id: posting.consolidation_id, status: posting.status, white_glove: posting.white_glove)
      posting.update(responded: true)
      if posting.order_id.present?
        posting.order.comments.create(description: "Shipping invoice posted for payment.", commentable_id: posting.order_id, commentable_type: "Order")
      elsif posting.return_id.present?
        posting.return.comments.create(description: "Shipping invoice posted for payment.", commentable_id: posting.return_id, commentable_type: "Return")
      elsif posting.consolidation_id.present?
        posting.consolidation.comments.create(description: "Shipping invoice posted for payment.", commentable_id: posting.consolidation_id, commentable_type: "Consolidation")
      end
    end
    redirect_to posting_admin_billing_sections_path
  end

  def records
    if params[:result].present? && params[:result] == "undo"
      @record = RecordSection.find(params[:record_id])
      @posting = PostingSection.find_by(order_id: @record.order_id, store: @record.store, shipping_detail_id: @record.shipping_detail_id, responded: true, invoice_type: @record.invoice_type, return_id: @record.return_id, consolidation_id: @record.consolidation_id, white_glove: @record.white_glove)
      if @posting.present?
        @posting.update(dispute_pay_reason: nil, dispute_not_paid_reason: nil, responded: nil, posted: @record.posted, status: nil)
        @record.destroy
      end
      redirect_to records_admin_billing_sections_path
    else
      @pagy, @records = pagy(RecordSection.where(store: current_store), items_param: :per_page, max_items: 100)
      @filter ||= nil
    end
  end

  def report_invoice
    @records = RecordSection.where(store: params[:store], responded: nil)

    @records = @records.where("record_sections.created_at >= ?", params[:start_date]) if params[:start_date].present?
    @records = @records.where("record_sections.created_at <= ?", params[:end_date]) if params[:end_date].present?

    @records = @records.eager_load(shipping_detail: [:carrier, :white_glove_address]).where("(white_glove_addresses.company = ? AND record_sections.white_glove IS TRUE) OR (carriers.name = ? AND record_sections.invoice_type IS TRUE)", params[:carrier], params[:carrier]) if params[:carrier].present?
  end

  
  def delete_upload
    attachment = ActiveStorage::Attachment.find_by(id: params[:doc_id])
    attachment.purge if attachment.present?
    redirect_to request.referrer
  end

  private

  def invoice_params
    params.require(:invoice_for_billing).permit(:invoice_number, :invoice_amount, :invoice_date, :invoice_due_date, :invoice_difference, :tax, :qst, files: [])
  end

  def invoice_wgd_params
    params.require(:invoice_for_wgd).permit(:invoice_number, :invoice_amount, :invoice_date, :invoice_due_date, :invoice_difference, :tax, :qst, files: [])
  end
end
