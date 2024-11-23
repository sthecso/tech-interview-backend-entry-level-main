class Cart < ApplicationRecord
  STATE = ["active", "abandoned"]

  has_many :cart_items
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  validates :state, presence: true, inclusion: { in: STATE }

  def sum_total_price
    self.total_price = cart_items.sum(&:total_price).to_f
  end
end
