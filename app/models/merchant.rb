# frozen_string_literal: true

# == Schema Information
#
# Table name: merchants
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  cif        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Merchant < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
  validates :cif, presence: true
end
