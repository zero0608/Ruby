module Admin::PurchasesHelper

  def purchase_del
    Purchase.eager_load(:purchase_items, :supplier).all.each do |p|
      p.destroy if !(p.purchase_items.present?)
    end
  end
end
