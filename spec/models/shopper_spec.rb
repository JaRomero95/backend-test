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
require 'rails_helper'

RSpec.describe Shopper, type: :model do
  let(:instance) { build :shopper }

  describe 'Validations' do
    it 'is not valid without a name' do
      instance.name = ''

      expect(instance).not_to be_valid
    end

    it 'is not valid without a email' do
      instance.email = ''

      expect(instance).not_to be_valid
    end

    it 'is not valid without a nif' do
      instance.nif = ''

      expect(instance).not_to be_valid
    end
  end
end
