# frozen_string_literal: true

# == Schema Information
#
# Table name: shoppers
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  nif        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Shopper < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
  validates :nif, presence: true
end
