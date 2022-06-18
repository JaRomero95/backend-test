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
class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :shopper

  validates :amount, presence: true
end
