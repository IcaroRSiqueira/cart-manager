class CartSerializer < ActiveModel::Serializer
  attribute :id
  attribute :products
  attribute :total_price

  def products
    object.cart_items.map do |cart_item|
      {
        id: cart_item.product.id,
        name: cart_item.product.name,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price,
        total_price: cart_item.quantity * cart_item.product.price
      }
    end
  end
end
