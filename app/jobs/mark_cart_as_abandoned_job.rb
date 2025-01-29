require 'sidekiq-scheduler'

class MarkCartAsAbandonedJob
  include Sidekiq::Worker

  def perform
    Cart.inactive_for_3_hours.each(&:mark_as_abandoned!)
    Cart.abandoned_for_7_days.each(&:delete)
  end
end
