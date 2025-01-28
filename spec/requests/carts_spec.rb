require 'rails_helper'

RSpec.describe "/cart", type: :request do
  describe "POST /add_items" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }
    let!(:cart_item) { create(:cart_item, cart_id: cart.id, product_id: product.id, quantity: 1) }

    context 'when the product already is in the cart' do

      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      let(:expected_response) do
        {
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 3,
              unit_price: product.price,
              total_price: '30.0'
            }
          ],
          total_price: '30.0'
        }.to_json
      end

      it 'returns 201' do
        subject

        expect(response).to have_http_status(:created)
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end

      it 'returns cart information with products' do
        subject

        expect(response.body).to eq(expected_response)
      end
    end

    context 'when product is not in the cart' do
      let(:another_product) { Product.create(name: "Another Product", price: 15.0) }
      subject do
        post '/cart/add_item', params: { product_id: another_product.id, quantity: 1 }, as: :json
      end

      let(:expected_response) do
        {
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 1,
              unit_price: product.price,
              total_price: '10.0'
            },
            {
              id: another_product.id,
              name: another_product.name,
              quantity: 1,
              unit_price: another_product.price,
              total_price: '15.0'
            },
          ],
          total_price: '25.0'
        }.to_json
      end

      it 'returns 201' do
        subject

        expect(response).to have_http_status(:created)
      end

      it 'updates the quantity of products inside the cart' do
        expect { subject }.to change { cart.cart_items.reload.count }.by(1)
      end

      it 'returns cart information with products' do
        subject

        expect(response.body).to eq(expected_response)
      end
    end

    context 'when cart does not exists' do
      let!(:cart) { Cart.delete_all }
      let!(:cart_item) { nil }
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      let(:expected_response) do
        {
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 1,
              unit_price: '10.0',
              total_price: '10.0'
            }
          ],
          total_price: '10.0'
        }
      end

      it 'returns 201' do
        subject

        expect(response).to have_http_status(:created)
      end

      it 'creates a new cart' do
        expect { subject }.to change { Cart.count }.by(1)
      end

      it 'updates the quantity of products inside the cart' do
        subject
        created_cart = Cart.last

        expect(created_cart.reload.cart_items.count).to eq(1)
      end

      it 'returns cart information with products' do
        subject
        created_cart = Cart.last

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response.merge(id: created_cart.id))
      end
    end

    context 'when product does not exists' do
      subject do
        post '/cart/add_item', params: { product_id: 9999, quantity: 1 }, as: :json
      end

      it 'returns 422' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject

        expect(response.body).to include('Could not find product with id 9999')
      end
    end
  end

  describe "GET/" do
    subject do
      get '/cart'
    end

    context 'when cart exists' do
      let(:cart) { create(:cart, total_price: 55) }
      let(:product) { create(:product, price: 15.0) }
      let!(:cart_item) { create(:cart_item, cart_id: cart.id, product_id: product.id, quantity: 1) }
      let(:another_product) { create(:product, price: 20.0) }
      let!(:another_cart_item) { create(:cart_item, cart_id: cart.id, product_id: another_product.id, quantity: 2) }

      let(:expected_response) do
        {
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 1,
              unit_price: product.price,
              total_price: '15.0'
            },
            {
              id: another_product.id,
              name: another_product.name,
              quantity: 2,
              unit_price: another_product.price,
              total_price: '40.0'
            },
          ],
          total_price: '55.0'
        }.to_json
      end



      it 'returns 200' do
        subject

        expect(response).to have_http_status(:ok)
      end

      it 'returns cart information with products' do
        subject

        expect(response.body).to eq(expected_response)
      end
    end

    context 'when cart does not exists' do
      let(:expected_response) do
        {
          products: [],
          total_price: '0.0'
        }
      end
      it 'returns 200' do
        subject

        expect(response).to have_http_status(:ok)
      end

      it 'returns cart information without products' do
        subject
        created_cart = Cart.last

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response.merge(id: created_cart.id))
      end
    end
  end

  describe "DELETE/:product_id" do
    subject do
      delete "/cart/#{product_id}"
    end

    context 'when product exists' do
      let(:product_id) { product.id }
      context 'and there are remaining products inside cart' do
        let(:cart) { create(:cart, total_price: 55) }
        let(:product) { create(:product, price: 15.0) }
        let!(:cart_item) { create(:cart_item, cart_id: cart.id, product_id: product.id, quantity: 1) }
        let(:another_product) { create(:product, price: 20.0) }
        let!(:another_cart_item) { create(:cart_item, cart_id: cart.id, product_id: another_product.id, quantity: 2) }

        let(:expected_response) do
          {
            id: cart.id,
            products: [
              {
                id: another_product.id,
                name: another_product.name,
                quantity: 2,
                unit_price: another_product.price,
                total_price: '40.0'
              }
            ],
            total_price: '40.0'
          }.to_json
        end

        it 'returns 200' do
          subject

          expect(response).to have_http_status(:ok)
        end

        it 'updates the quantity of products inside the cart' do
          expect { subject }.to change { cart.cart_items.reload.count }.by(-1)
        end

        it 'returns cart information without removed product' do
          subject

          expect(response.body).to eq(expected_response)
        end
      end

      context 'and there are no items left in the cart' do
        let(:cart) { create(:cart, total_price: 55) }
        let(:product) { create(:product, price: 15.0) }
        let!(:cart_item) { create(:cart_item, cart_id: cart.id, product_id: product.id, quantity: 1) }

        let(:expected_response) do
          {
            id: cart.id,
            products: [],
            total_price: '0.0'
          }.to_json
        end

        it 'returns 200' do
          subject

          expect(response).to have_http_status(:ok)
        end

        it 'updates the quantity of products inside the cart' do
          expect { subject }.to change { cart.cart_items.reload.count }.by(-1)
        end

        it 'returns cart without products' do
          subject

          expect(response.body).to eq(expected_response)
        end
      end

      context 'when product does not exists' do
        let(:product_id) { 99999 }

        it 'returns 422' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error message' do
          subject

          expect(response.body).to include('Could not find product with id 99999 inside the cart')
        end
      end
    end
  end
end
