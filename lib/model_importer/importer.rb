# frozen_string_literal: true

module ModelImporter
  # Import resources to the database from a data file
  class Importer
    def initialize(model:, file_path:, reader_class:, formatters: {})
      @model = model
      @file_path = file_path
      @reader_class = reader_class
      @formatters = formatters.with_indifferent_access
    end

    def run
      content = @reader_class.new(@file_path).content

      format_content(content)

      @model.insert_all!(content) # rubocop:disable Rails/SkipsModelValidations
    end

    private

    def format_content(content)
      content.each { |element| format_element(element) }
    end

    def format_element(element)
      element.each_key { |key| format_field(element, key) }
    end

    def format_field(element, key)
      formatter = @formatters[key]

      return unless formatter

      value = element[key]

      element[key] = formatter.call(value)
    end
  end
end
