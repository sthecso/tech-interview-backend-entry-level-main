require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show' do
      get :show
      expect(get: '/cart').to route_to('carts#show')
    end

    it 'routes to #create' do
      # TODO
      let(:product) { create(:product) }

      post :create, params: { cart: { product_id: 2, quantity: 4 } }
    end

    it 'routes to #add_item via POST' do
      expect(post: '/cart/add_item').to route_to('carts#add_item')
    end
  end
end 
