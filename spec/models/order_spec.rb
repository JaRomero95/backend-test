# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  merchant_id  :integer          not null
#  shopper_id   :integer          not null
#  amount       :integer
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:instance) { build :order }

  describe 'Validations' do
    it 'is not valid without an merchant' do
      instance.merchant = nil

      expect(instance).not_to be_valid
    end

    it 'is not valid without an shopper' do
      instance.shopper = nil

      expect(instance).not_to be_valid
    end

    it 'is not valid without an amount' do
      instance.amount = ''

      expect(instance).not_to be_valid
    end
  end
end
