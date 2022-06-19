# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeeCalculator do
  it 'calculates a 1% fee for amount smaller than 50€' do
    expect_fee(initial_euros: 49.99, expected_euros: 0.50) # always rounds up
  end

  it 'calculates a 0.95% fee for amounts starting at 50€' do
    expect_fee(initial_euros: 50, expected_euros: 0.48)
  end

  it 'calculates a 0.95% fee for amounts up to 300€' do
    expect_fee(initial_euros: 300, expected_euros: 2.85)
  end

  it 'calculates a 0.85% fee for amounts greater than 300€' do
    # round up but only to first 2 decimal places of cent, ignore extra decimal places to round
    expect_fee(initial_euros: 300.01, expected_euros: 2.55)
  end

  def expect_fee(initial_euros:, expected_euros:)
    result = calculate(euros_to_cents(initial_euros))

    expected_fee = euros_to_cents(expected_euros)

    expect(result).to eq(expected_fee)
  end

  def euros_to_cents(euros)
    (euros.to_d * 100).to_i
  end

  delegate :calculate, to: :described_class
end
