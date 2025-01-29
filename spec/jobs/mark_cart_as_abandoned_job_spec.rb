# frozen_string_literal: true

require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  subject { MarkCartAsAbandonedJob.new.perform }

  context 'when there are carts inactive for more than 3 hours' do
    let(:cart) { create(:cart, updated_at: Date.current - 4.hours) }
    it 'sets cart as abandoned' do
      expect { subject }.to change { cart.reload.abandoned }.from(false).to(true)
    end
  end

  context 'when there are abandoned carts for more than 7 hours' do
    let!(:cart) { create(:cart, updated_at: Date.current - 8.days, abandoned: true) }
    it 'sets cart as abandoned' do
      expect { subject }.to change { Cart.count }.by(-1)
    end
  end
end
