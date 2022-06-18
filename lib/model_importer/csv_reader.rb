# frozen_string_literal: true

require 'csv'
require_relative 'errors'

module ModelImporter
  # Read a CSV file and parse it to a Hash
  class CsvReader
    def initialize(file_path)
      @file_path = file_path
    end

    def content
      return @content if @content

      @content = read_file

      raise InvalidFileError if @content.empty?

      @content
    rescue Errno::ENOENT
      raise InvalidFileError
    end

    private

    def read_file
      CSV.read(@file_path, headers: true).map(&:to_h)
    end
  end
end
