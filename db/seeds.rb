# frozen_string_literal: true

require 'model_importer/model_importer'

ModelImporter::Importer.new(
  model: Shopper,
  file_path: 'db/seeds/shoppers.csv',
  reader_class: ModelImporter::CsvReader
).run

ModelImporter::Importer.new(
  model: Merchant,
  file_path: 'db/seeds/merchants.csv',
  reader_class: ModelImporter::CsvReader
).run

ModelImporter::Importer.new(
  model: Order,
  file_path: 'db/seeds/orders.csv',
  reader_class: ModelImporter::CsvReader,
  formatters: {
    amount: ->(value) { value.to_f * 100 }
  }
).run
