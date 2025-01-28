class AddCartItemService
  attr_reader :product_id, :quantity

  def initialize(product_id:, quantity:)
    @product_id = product_id
    @quantity = quantity
  end

  def call
    existing_cart_item.present? ? update_quantity : create_cart_item
    update_cart_total_price
  end

  private

  def update_cart_total_price
    total_price = cart.cart_items.sum do |cart_item|
      cart_item.quantity * cart_item.product.price
    end
    cart.update!(total_price: total_price)
  end

  def create_cart_item
    CartItem.create!(cart: cart, product: product, quantity: quantity)
  end

  def update_quantity
    existing_cart_item.increment!(:quantity, quantity)
  end

  def existing_cart_item
    cart.cart_items.find_by(product_id: product_id)
  end

  def cart
    Cart.last
  end

  def product
    Product.find(product_id)
  end
end
