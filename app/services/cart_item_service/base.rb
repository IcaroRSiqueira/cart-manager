module CartItemService
  class Base
    private

    def cart
      Cart.find_by_id(cart_id)
    end

    def update_cart_total_price
      total_price = cart.cart_items.sum do |cart_item|
        cart_item.quantity * cart_item.product.price
      end
      cart.update!(total_price: total_price)
    end
  end
end
