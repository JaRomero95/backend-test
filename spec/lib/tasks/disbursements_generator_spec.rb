# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'disbursements:generator', type: :task do
  let(:task) { Rake::Task['disbursements:generator'] }

  before do
    allow(DisbursementsGeneratorJob).to receive(:perform_now)
  end

  context 'without date argument' do
    it 'calls generator for the past week' do
      task.execute

      expected_date = (Date.today - 1.week).strftime('%d/%m/%Y')

      expect(DisbursementsGeneratorJob).to have_received(:perform_now).with(expected_date)
    end
  end

  context 'with date argument' do
    it 'calls generator with the sent date' do
      date = '31/01/2022'

      task.execute(date:)

      expect(DisbursementsGeneratorJob).to have_received(:perform_now).with(date)
    end
  end
end
