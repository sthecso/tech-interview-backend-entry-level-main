class CartsController < ApplicationController
  before_action :set_cart

  def create
    product = find_product(cart_params[:product_id])
    cart_item = @cart.cart_items.find_by(product:)
    quantity = params[:quantity].to_i
    
    if cart_item
      cart_item.quantity += quantity
      cart_item.save!
    else
      @cart.cart_items.create(
        product_id: cart_params[:product_id],
        quantity: cart_params[:quantity]
        )
    end

    render json: format_cart(@cart)
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Product not found: #{e.message}" }, status: :not_found
  end
    
  def show
    render json: format_cart(@cart)
  end
    
  def add_item
    product = find_product(cart_params[:product_id])
    quantity = params[:quantity].to_i
    
    cart_item = @cart.cart_items.find_by(product: product)
    
    if cart_item
    cart_item.quantity += quantity
    cart_item.save!
    else
      @cart.cart_items.create!(product: product, quantity: quantity)
    end

    render json: format_cart(@cart), status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Product not found: #{e.message}" }, status: :not_found
  rescue StandardError => e
    render json: { error: "Something went wrong: #{e.message}" }, status: :unprocessable_entity
  end
  
  def remove_cart_item
    product = find_product(cart_params[:product_id])
    cart_item = @cart.cart_items.find_by(product:)
    
    unless cart_item
      render json: { error: "Product does not exist in this cart, try again"}, status: :not_found and return
    end
    
    cart_item.destroy!
    render json: format_cart(@cart), status: :ok
  end
  
  private
  
  def set_cart
    @cart = Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] ||= @cart.id
  end
  
  def find_product(product)
    Product.find(product)
  end
  
  def format_cart(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.total_price
        }
      end,
      total_price: cart.total_price
    }
  end

  def cart_params
    params.except(:cart).permit(:product_id, :quantity)
  end
end
