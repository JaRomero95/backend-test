# frozen_string_literal: true

class Disbursement < ApplicationRecord
  include Filterable

  belongs_to :order

  validates :amount, presence: true
end
