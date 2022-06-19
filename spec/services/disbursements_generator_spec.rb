# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisbursementsGenerator do
  let(:date) { Time.zone.today }
  let(:amount) { 100 }
  let(:fee_amount) { 10 }
  let(:disbursed_amount) { amount - fee_amount }

  before do
    allow(FeeCalculator).to receive(:calculate).and_return(fee_amount)
  end

  context 'with orders' do
    let!(:merchant) { create :merchant }

    let!(:order) do
      create :order, completed_at: Time.zone.now, merchant:, amount:
    end

    let(:disbursement) { Disbursement.first }

    it 'generates disbursement' do
      expect { run }.to(change { Disbursement.count }.from(0).to(1))
    end

    it 'sets order id' do
      run

      expect(disbursement.order_id).to eq(order.id)
    end

    it 'calculates amount to disburse' do
      run

      expect(disbursement.amount).to eq(disbursed_amount)
    end
  end

  context 'with several merchants' do
    let!(:merchant_one) { create :merchant }
    let!(:merchant_two) { create :merchant }

    let!(:orders_merchant_one) do
      create_list :order, 2, completed_at: Time.zone.now, merchant: merchant_one
    end

    let!(:orders_merchant_two) do
      create_list :order, 2, completed_at: Time.zone.now, merchant: merchant_two
    end

    it 'generates a disbursement for each order' do
      total_orders = orders_merchant_one + orders_merchant_two

      expect { run }.to(change { Disbursement.distinct(:order_id).count }.to(total_orders.count))
    end
  end

  context 'without orders' do
    let!(:merchant) { create :merchant }

    it 'does not generates disbursements' do
      expect { run }.not_to(change { Disbursement.count })
    end
  end

  context 'with orders not completed in the targetted date range' do
    let!(:merchant) { create :merchant }

    it 'does not generates disbursements with orders from previous weeks' do
      create :order, completed_at: (date - 1.week)

      expect { run }.not_to(change { Disbursement.count })
    end

    it 'does not generates disbursements with orders from next weeks' do
      create :order, completed_at: (date + 1.week)

      expect { run }.not_to(change { Disbursement.count })
    end

    it 'does not generate disbursements if there are no completed orders' do
      create :order, completed_at: nil

      expect { run }.not_to(change { Disbursement.count })
    end
  end

  def run
    described_class.new(date:).run
  end
end
