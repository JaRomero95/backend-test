# frozen_string_literal: true

module ModelImporter
  class ModelImporterError < StandardError
  end

  class InvalidFileError < ModelImporterError
  end
end
