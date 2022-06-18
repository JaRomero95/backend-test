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
require 'rails_helper'

RSpec.describe Merchant, type: :model do
  let(:instance) { build :merchant }

  describe 'Validations' do
    it 'is not valid without a name' do
      instance.name = ''

      expect(instance).not_to be_valid
    end

    it 'is not valid without a email' do
      instance.email = ''

      expect(instance).not_to be_valid
    end

    it 'is not valid without a cif' do
      instance.cif = ''

      expect(instance).not_to be_valid
    end
  end
end
