# frozen_string_literal: true

# Generate a disbursement for each merchant based in completed orders
class DisbursementsGenerator
  def initialize(date:)
    initialize_datetime_range(date)
  end

  def run
    disbursements = orders.map { |order| disbursement_from_order(order) }

    # rubocop:disable Rails/SkipsModelValidations
    Disbursement.insert_all! disbursements if disbursements.any?
    # rubocop:enable Rails/SkipsModelValidations
  end

  private

  def initialize_datetime_range(date)
    datetime = date.to_datetime

    @start_datetime = datetime.beginning_of_week(:monday)
    @end_datetime = datetime.end_of_week
  end

  def orders
    Order.where(completed_at: @start_datetime..@end_datetime)
  end

  def disbursement_from_order(order)
    fee = FeeCalculator.calculate(order.amount)

    disbursed_amount = order.amount - fee

    { order_id: order.id, amount: disbursed_amount }
  end
end
