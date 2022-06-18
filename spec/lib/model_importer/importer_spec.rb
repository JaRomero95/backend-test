# frozen_string_literal: true

require 'rails_helper'
require 'model_importer/importer'

RSpec.describe ModelImporter::Importer do
  let(:file_path) { double('file_path_example.csv') }
  let(:reader_class) { double('ReaderClass') }
  let(:content) do
    [
      { id: '1', name: 'lorem ipsum' },
      { id: '2', name: 'dolor et' }
    ]
  end
  let(:model) { double('ActiveRecordModel') }

  before do
    allow(reader_class).to receive(:new).with(file_path).and_return(reader_class)
    allow(reader_class).to receive(:content).and_return(content.dup.map(&:dup))
    allow(model).to receive(:insert_all!)
  end

  it 'inserts all resources' do
    run

    expect_insert_content(content)
  end

  it 'uses received formatters' do
    run(formatters: { name: ->(value) { value.upcase } })

    content.each { |element| element[:name] = element[:name].upcase }

    expect_insert_content(content)
  end

  def expect_insert_content(content)
    expect(model).to have_received(:insert_all!).with(
      array_including(*content)
    )
  end

  def run(attrs = {})
    default_attrs = {
      model:,
      reader_class:,
      file_path:
    }

    described_class.new(**default_attrs.merge(attrs)).run
  end
end
