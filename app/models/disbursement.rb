# frozen_string_literal: true

class Disbursement < ApplicationRecord
  include Filterable

  belongs_to :order

  validates :amount, presence: true

  class << self
    def filter_by_merchant_id(merchant_id)
      joins(:order).where(order: {merchant_id:})
    end

    def filter_by_date_week(date_week)
      date = Date.strptime(date_week, '%d/%m/%Y')

      joins(:order).where(order: {completed_at: date.beginning_of_week..date.end_of_week})
    rescue Date::Error
      none
    end
  end
end
