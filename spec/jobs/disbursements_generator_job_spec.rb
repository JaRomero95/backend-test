# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisbursementsGeneratorJob, type: :job do
  let(:generator) { double('DisbursementsGenerator') }
  let(:strdate) { '28/02/2022' }

  before do
    allow(DisbursementsGenerator).to receive(:new).and_return(generator)
    allow(generator).to receive(:run)
  end

  context 'with a valid date string' do
    it 'can be enqueued' do
      expect { perform(strdate) }.to have_enqueued_job
    end

    it 'initializes the service with a date' do
      perform_enqueued_jobs { perform(strdate) }

      date = Date.strptime(strdate, '%d/%m/%Y')

      expect(DisbursementsGenerator).to have_received(:new).with(date:)
    end

    it 'runs the service' do
      perform_enqueued_jobs { perform(strdate) }

      expect(generator).to have_received(:run)
    end
  end

  context 'with a invalid date string' do
    it 'does not call the generator' do
      perform_enqueued_jobs { perform('invalid') }

      expect(DisbursementsGenerator).not_to have_received(:new)
    end
  end

  def perform(strdate)
    described_class.perform_later(strdate)
  end
end
