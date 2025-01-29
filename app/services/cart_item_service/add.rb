module CartItemService
  class Add < Base
    attr_reader :product_id, :quantity, :cart_id

    def initialize(product_id:, quantity:, cart_id:)
      @product_id = product_id
      @quantity = quantity
      @cart_id = cart_id
    end

    def call
      existing_cart_item.present? ? update_quantity : create_cart_item
      update_cart_total_price
      sets_cart_abandoned_to_false_when_necessary
    end

    private

    def create_cart_item
      CartItem.create!(cart: cart, product: product, quantity: quantity)
    end

    def update_quantity
      existing_cart_item.increment!(:quantity, quantity)
    end

    def existing_cart_item
      cart.cart_items.find_by(product_id: product_id)
    end

    def product
      product = Product.find_by_id(product_id)
      raise CartItemService::Exception.new("Could not find product with id #{product_id}") unless product

      product
    end
  end
end
