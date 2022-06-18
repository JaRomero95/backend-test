# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    merchant
    shopper
    amount { rand(20..5000) }
    completed_at { Faker::Date.backward }
  end
end
