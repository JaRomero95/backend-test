class DisbursementsController < ApplicationController
  def index
    disbursements = Disbursement.filter(filter_params)

    render_index(disbursements)
  end

  private

  def filter_params
    params.fetch(:filter, {}).permit(:merchant_id, :date_week)
  end
end
