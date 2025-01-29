require 'rails_helper'

describe CartItemService::Remove do
  describe '#call' do
    subject do
      CartItemService::Remove.new(product_id: product_id, cart_id: cart.id).call
    end

    let(:cart) { create(:cart, total_price: 10) }

    context 'when product exists on cart' do
      let(:product_id) { product.id }
      let(:product) { create(:product, price: 10.0) }
      let!(:cart_item) { create(:cart_item, cart_id: cart.id, product_id: product.id, quantity: 1) }

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart.reload.cart_items.count }.by(-1)
      end

      it 'updates the total price from cart' do
        expect { subject }.to change { cart.reload.total_price }.from(10).to(0)
      end

      context 'if cart was abandoned' do
        let(:cart) { create(:cart, total_price: 10, abandoned: true) }

        it 'sets abandoned as false when updated' do
          expect { subject }.to change { cart.reload.abandoned }.from(true).to(false)
        end
      end
    end

    context 'when product does not exists on cart' do
      let(:another_product) { create(:product, price: 25.0) }
      let(:product_id) { another_product.id }


      it 'Raises an exception' do
        expect { subject }.to raise_error(CartItemService::Exception,
                                          "Could not find product with id #{product_id} inside the cart")
      end
    end
  end
end
