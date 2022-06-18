# frozen_string_literal: true

FactoryBot.define do
  factory :shopper do
    name { Faker::Name.name }
    email  { Faker::Internet.email }
    nif { Faker::IDNumber.spanish_citizen_number }
  end
end
