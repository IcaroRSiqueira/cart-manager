module CartItemService
  class Remove < Base
    class Exception < StandardError; end
    attr_reader :product_id

    def initialize(product_id:)
      @product_id = product_id
    end

    def call
      remove_cart_item
      update_cart_total_price
    end

    private

    def remove_cart_item
      cart_item = cart.cart_items.find_by(product_id: product_id)
      raise CartItemService::Exception.new("Could not find product with id #{product_id} inside the cart") unless cart_item

      cart_item.delete
    end
  end
end
