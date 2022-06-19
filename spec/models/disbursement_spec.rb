# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Disbursement, type: :model do
  let(:instance) { build :disbursement }

  it 'is not valid without a amount' do
    instance.amount = nil

    expect(instance).not_to be_valid
  end

  it 'is not valid without a order' do
    instance.order = nil

    expect(instance).not_to be_valid
  end
end
