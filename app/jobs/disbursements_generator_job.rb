# frozen_string_literal: true

# Allows to run DisbursementsGenerator in background
class DisbursementsGeneratorJob < ApplicationJob
  queue_as :default

  def perform(strdate)
    begin
      date = Date.strptime(strdate, '%d/%m/%Y')
    rescue Date::Error
      return
    end

    DisbursementsGenerator.new(date:).run
  end
end
