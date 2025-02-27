# frozen_string_literal: true

module CartItemService
  class Remove < Base
    class Exception < StandardError; end
    attr_reader :product_id, :cart_id

    def initialize(product_id:, cart_id:)
      @product_id = product_id
      @cart_id = cart_id
    end

    def call
      remove_cart_item
      update_cart_total_price
      sets_cart_abandoned_to_false_when_necessary
    end

    private

    def remove_cart_item
      cart_item = cart.cart_items.find_by(product_id: product_id)
      raise CartItemService::Exception, "Could not find product with id #{product_id} inside the cart" unless cart_item

      cart_item.delete
    end
  end
end
