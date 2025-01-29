# frozen_string_literal: true

require 'rails_helper'

describe CartSerializer, type: :serializer do
  let(:cart) { create(:cart, total_price: 10.0) }
  let(:product) { create(:product) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product) }
  let(:serialized_cart) { ActiveModelSerializers::Adapter.create(serializer).as_json }

  context 'when should retrieve suborganizations and parent info' do
    let(:serializer) { described_class.new(cart) }

    it 'contains the expected keys' do
      expected_keys = %i[
        id
        products
        total_price
      ]

      expect(serialized_cart.keys.sort).to eq(expected_keys.sort)
    end

    it 'serializes expected attributes' do
      expect(serialized_cart).to eq(
        id: cart.id,
        products: [
          {
            id: product.id,
            name: product.name,
            quantity: 1,
            unit_price: product.price,
            total_price: product.price
          }
        ],
        total_price: product.price
      )
    end
  end
end
