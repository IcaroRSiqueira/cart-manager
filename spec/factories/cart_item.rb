# frozen_string_literal: true

FactoryBot.define do
  factory :cart_item do
    product
    cart
    quantity { 1 }
  end
end
