# frozen_string_literal: true

require 'rails_helper'
require 'model_importer/csv_reader'

RSpec.describe ModelImporter::CsvReader do
  context 'when csv file is correct' do
    let(:headers) { %w[id name] }
    let(:values) { ['1', 'lorem ipsum'] }

    let(:csv_file) { generate_file("#{headers.join(',')}\n#{values.join(',')}") }

    let(:result) { read_content(csv_file.path) }
    let(:item) { result[0] }

    it 'returns file content as array' do
      expect(result).to be_an(Array)
    end

    it 'returns items with header as keys' do
      expect(item.keys).to eq(headers)
    end

    it 'returns items with correct values' do
      expect(item.values).to eq(['1', 'lorem ipsum'])
    end
  end

  context 'when file is not valid' do
    it 'raises an error if file not exists' do
      expect { read_content('invalid_file') }.to raise_error(ModelImporter::InvalidFileError)
    end

    it 'raises an error if file is empty' do
      file = generate_file('')

      expect { read_content(file.path) }.to raise_error(ModelImporter::InvalidFileError)
    end

    it 'raises an error if file cannot be parsed' do
      file = generate_file('invalid_csv')

      expect { read_content(file.path) }.to raise_error(ModelImporter::InvalidFileError)
    end
  end

  def generate_file(content)
    Tempfile.new(['example', '.csv']).tap do |file|
      file.write(content)
      file.close
    end
  end

  def read_content(file_path)
    described_class.new(file_path).content
  end
end
