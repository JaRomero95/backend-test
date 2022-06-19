module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def filter(params)
      scope = self.where(nil)

      params.each do |key, value|
        scope = scope.public_send("filter_by_#{key}", value)
      end

      scope
    end
  end
end
