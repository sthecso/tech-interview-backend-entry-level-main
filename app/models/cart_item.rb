class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  after_commit :update_cart_total_price
  
  def total_price
    quantity * product.price
  end

  private

  def update_cart_total_price
    cart.sum_total_price
    cart.save
  end
end
