# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    name { Faker::Name.name }
    email  { Faker::Internet.email }
    cif { Faker::Company.spanish_organisation_number }
  end
end
