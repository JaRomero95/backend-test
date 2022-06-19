# frozen_string_literal: true

# Generate a disbursement for each merchant based in completed orders
class FeeCalculator
  class << self
    def calculate(amount)
      percentage = if amount < euros_to_cents(50)
                     1
                   elsif amount <= euros_to_cents(300)
                     0.95
                   else
                     0.85
                   end

      multiplier = percentage_to_multiplier(percentage)

      (amount * multiplier).truncate(2).ceil
    end

    private

    def euros_to_cents(euros)
      euros.to_d * 100
    end

    def percentage_to_multiplier(percentage)
      percentage.to_d / 100
    end
  end
end
