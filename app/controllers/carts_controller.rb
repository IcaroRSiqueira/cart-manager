class CartsController < ApplicationController
  rescue_from CartItemService::Exception, with: :exception_handler
  before_action :set_cart

  def add_item
    CartItemService::Add.new(
      product_id: permitted_params[:product_id],
      quantity: permitted_params[:quantity],
      cart_id: @cart.id
    ).call

    render json: @cart.reload, serializer: CartSerializer, status: :created
  end

  def remove_item
    CartItemService::Remove.new(
      product_id: permitted_params[:product_id],
      cart_id: @cart.id
    ).call

    render json: @cart.reload, serializer: CartSerializer, status: :ok
  end

  def show
    render json: @cart.reload, serializer: CartSerializer
  end

  private

  def permitted_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    @cart = Cart.find_by_id(session[:cart_id]) || Cart.create!(total_price: 0)
    session[:cart_id] = @cart.id
  end

  def exception_handler(exception)
    render json: { message: exception.message }, status: :unprocessable_entity
  end
end
