class Admin::SuppliersController < ApplicationController

  before_action :find_supplier, only: [:edit, :update, :destroy, :add_user, :purchase]

  def index
    if current_user.user_group.admin_view
      @suppliers = Supplier.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
      redirect_to admin_suppliers_path, success: "Supplier created successfully."
    else
      render 'new'
    end
  end

  def edit
    if current_user.user_group.admin_cru
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to admin_suppliers_path, success: "Supplier updated successfully."
    else
      render 'edit'
    end
  end

  def add_user
  end

  def destroy
    @supplier.destroy
    redirect_to admin_suppliers_path
  end

  def purchase
    @PurchaseItem = PurchaseItem.eager_load(:line_item, line_item: [:order]).where("line_item_id IS NULL or (orders.status != ? and orders.status != ?)", Order.statuses[:cancel_confirmed], Order.statuses[:completed])
    if params[:item_type] == "not_started"
      @purchase_items = @PurchaseItem.joins(:purchase).where(status: "not_started", purchases: { supplier_id: @supplier.id, store: current_store })
    elsif params[:item_type] == "in_production"
      @purchase_items = @PurchaseItem.joins(:purchase).where(status: "in_production", purchases: { supplier_id: @supplier.id, store: current_store })
    elsif params[:item_type] == "over_5_days"
      @purchase_items = @PurchaseItem.joins(:purchase).where(status: ["not_started", "in_production"], purchases: { supplier_id: @supplier.id, store: current_store }).where("purchases.created_at < ?", Time.now - 5.days)
    elsif params[:item_type] == "container_ready"
      @purchase_items = @PurchaseItem.joins(:purchase).where(status: "container_ready", purchases: { supplier_id: @supplier.id, store: current_store })
    else
      @purchase_items = @PurchaseItem.joins(:purchase).where(status: ["not_started", "in_production", "container_ready"], purchases: { supplier_id: @supplier.id, store: current_store })
    end
  end

  private

  def find_supplier
    @supplier = Supplier.find_by(slug: params[:slug])
  end

  def supplier_params
    params.require(:supplier).permit(:name)
  end
end