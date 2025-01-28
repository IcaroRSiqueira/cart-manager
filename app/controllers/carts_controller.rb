class CartsController < ApplicationController
  before_action :set_cart

  def add_item
    AddCartItemService.new(
      product_id: permitted_params[:product_id],
      quantity: permitted_params[:quantity]
      ).call
    render json: @cart.reload, serializer: CartSerializer
  end

  private

  def permitted_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    @cart = Cart.last || Cart.create!(total_price: 0)
  end
end
