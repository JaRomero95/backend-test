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

next_date = Date.new
while next_date.present?
  next_date = Order.where.not(completed_at: nil)
                   .where.not(id: Disbursement.pluck(:order_id))
                   .first&.completed_at

  DisbursementsGenerator.new(date: next_date).run if next_date
end
