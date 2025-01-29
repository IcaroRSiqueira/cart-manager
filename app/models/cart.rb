# frozen_string_literal: true

class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items

  scope :inactive_for_3_hours, -> { where(updated_at: ..(Time.current - 3.hours)) }
  scope :abandoned_for_7_days, -> { where(abandoned: true, updated_at: ..(Time.current - 7.days)) }

  def mark_as_abandoned!
    update!(abandoned: true)
  end
end
