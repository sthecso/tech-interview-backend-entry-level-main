require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let(:cart) { Cart.create }
  let(:product) { Product.create(name: "Test Product", price: 10.0) }
  let!(:new_product) { Product.create(name: "Another Product", price: 20.0) }
  let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
    before do
      allow_any_instance_of(ApplicationController).to receive(:set_cart).and_return(cart)
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
    end

  describe "POST /cart" do
    context "when adding a new product" do
      it "adds the product to the cart" do
        expect {
          post '/cart', params: { product_id: new_product.id, quantity: 1 }, as: :json
        }.to change(Cart, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include("id", "products", "total_price")
      end

      it "returns the updated cart" do
        post '/cart', params: { product_id: new_product.id, quantity: 1 }, as: :json

        response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(response["products"].last["id"]).to eq(new_product.id)
      end
    end

    context "when the product does not exist" do
      it "returns a not found error" do
        post '/cart', params: { product_id: 99999, quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to include("Product not found")
      end
    end
  end

  describe "GET /cart" do
    it "returns the cart details as JSON" do
      get '/cart', as: :json

      response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(response["id"]).to eq(cart.id)
      expect(response["products"].size).to eq(1)
      expect(response["products"].first["id"]).to eq(product.id)
    end
  end

  describe "POST /add_item" do
    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found error' do
        post '/carts/add_item', params: { product_id: 99999, quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to include("Product not found")
      end
    end
  end

  describe "DELETE #remove_cart_item" do
    context "when the product exists in the cart" do
      it "removes the product from the cart" do
        expect {
          delete "/cart/#{product.id}", as: :json
        }.to change { cart.cart_items.count }.by(-1)
      end

      it "returns the updated cart as JSON" do
        delete "/cart/#{product.id}", as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"]).to be_empty
      end
    end

    context "when the product does not exist in the cart" do
      it "returns a not found error" do
        delete "/cart/#{product.id}", as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to include("Product does not exist in this cart")
      end
    end
  end
end
