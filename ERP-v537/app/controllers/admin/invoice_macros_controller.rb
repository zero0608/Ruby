class Admin::InvoiceMacrosController < ApplicationController
  def index
    if current_user.user_group.admin_view
      @invoice_macros = InvoiceMacro.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @invoice_macro = InvoiceMacro.new
  end

  def create
    @invoice_macro = InvoiceMacro.new(invoice_macro_params)
    if @invoice_macro.save
      redirect_to admin_invoice_macros_path, success: "Invoice macro created successfully."
    else
      render "new"
    end
  end

  def edit
    if current_user.user_group.admin_cru
      @invoice_macro = InvoiceMacro.find_by(id: params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @invoice_macro = InvoiceMacro.find_by(id: params[:id])
    if @invoice_macro.update(invoice_macro_params)
      redirect_to admin_invoice_macros_path, success: "Invoice macro updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @invoice_macro = InvoiceMacro.find_by(id: params[:id])
    @invoice_macro.destroy
    redirect_to admin_invoice_macros_path
  end

  private

  def invoice_macro_params
    params.require(:invoice_macro).permit(:id, :name, :description)
  end
end