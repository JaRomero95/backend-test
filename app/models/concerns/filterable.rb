# frozen_string_literal: true

# Allows to call several filter methods from a single hash
module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def filter(params)
      scope = where(nil)

      params.each do |key, value|
        scope = scope.public_send("filter_by_#{key}", value)
      end

      scope
    end
  end
end
