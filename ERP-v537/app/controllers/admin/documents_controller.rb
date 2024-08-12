class Admin::DocumentsController < ApplicationController
  include Pagy::Backend
  require "pagy/extras/items"

	
	def bol
		if params[:ship_ids].present?
			@shipping_details = ShippingDetail.eager_load(order: %i[customer shipping_details]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
			@shipping_details.uniq.each do |shipping_detail|
				shipping_detail.files.each do |doc|
					response.headers["Content-Type"] = doc.content_type
					response.headers["Content-Disposition"] = "form-data; name=#{doc.filename}"
					doc.download do |chunk|
						response.stream.write(chunk)
					end
					# send_data(doc.render, file_name: doc.file_name, type: doc.content_type)
				end
			end
		end
		@shipping_details = ShippingDetail.all
	end

	def doc_ids
		
		redirect_to bol_admin_documents_path
	end
end
