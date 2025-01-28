require 'rails_helper'

describe AddCartItemService do
  describe '#call' do
    subject do
      AddCartItemService.new(product_id: product_id, quantity: quantity).call
    end

    let(:cart) { create(:cart, total_price: 10) }
    let(:product) { create(:product, price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart_id: cart.id, product_id: product.id, quantity: 1) }

    context 'when product already exists on cart' do
      let(:product_id) { product.id }
      let(:quantity) { 3 }

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(3)
      end

      it 'updates the total price from cart' do
        expect { subject }.to change { cart.reload.total_price }.from(10).to(40)
      end
    end

    context 'when product does not exists on cart' do
      let(:another_product) { create(:product, price: 25.0) }
      let(:product_id) { another_product.id }
      let(:quantity) { 3 }

      it 'does not update the quantity of the existing item in the cart' do
        expect { subject }.not_to change { cart_item.reload.quantity }
      end

      it 'updates the quantity of products inside the cart' do
        expect { subject }.to change { cart.cart_items.reload.count }.by(1)
      end

      it 'updates the total price from cart' do
        expect { subject }.to change { cart.reload.total_price }.from(10).to(85)
      end
    end
  end
end
