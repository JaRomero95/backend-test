# frozen_string_literal: true

class ApplicationController < ActionController::API
  def render_index(data)
    paginated_data = data.page(page)

    render json: {
      data: paginated_data,
      metadata: {
        page:,
        page_count: paginated_data.size,
        per_page: Kaminari.config.default_per_page,
        total_count: data.count
      }
    }
  end

  def page
    (params.dig(:page, :number) || 1).to_i
  end
end
