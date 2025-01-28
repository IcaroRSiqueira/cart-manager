# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { 'Product Name' }
    price { 10.0 }
  end
end
