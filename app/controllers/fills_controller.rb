class FillsController < ApplicationController
  include ActionController::MimeResponds

  before_action :check_debug_key,
                only: %w(index report_by_date report_by_member)

  def create
    bio_id = params.require(:bio_id)
    fields = params.require(:fields)

    cm = CongressMember.find(bio_id) or return render json: {
      status: "error",
      message: "Congress member with provided bio id not found"
    }.to_json

    form = CongressForms::Form.find(cm.congress_forms_id)

    missing_parameters = []

    form.required_params.each do |field|
      unless fields.include?(field[:value])
        missing_parameters << field[:value]
      end
    end

    if missing_parameters.any?
      message = "Error: missing fields (#{missing_parameters.join(', ')})."
      return render json: { status: "error", message: message }.to_json
    end

    begin
      status =
        if form.fill(fields.permit!.to_h, submit: !params[:test])
          "success"
        else
          "failure"
        end
    rescue CongressForms::Error => e
      Raven.capture_message("Form error: #{bio_id}", tags: { "form_error" => true })
      CongressFormsFill.perform_later(cm.congress_forms_id, fields)
    ensure
      Fill.create(
        bioguide_id: bio_id,
        campaign_tag: params[:campaign_tag],
        status: status || "error",
        # screenshot: screenshot
      )
    end

    render json: { status: "success" }
  end

  def index
    if params[:all_statuses]
      fills = Fill.where(bioguide_id: params[:bio_id])
    else
      fills = Fill.recent(params[:bio_id])
    end

    render json: fills.order(updated_at: :desc)
  end

  def report
    fills = Fill.recent(params[:bio_id])

    respond_to do |format|
      format.svg do
        if fills.present?
          darkness = 0.8
          rate = fills.success.count / fills.count.to_f
          r = (1 - 2*[rate - 0.5, 0].max) * 255 * darkness
          g = [2*rate, 1].min * 255 * darkness
          b = 0
          name = sprintf("success-%d%%25-%02X%02X%02X",
                         (100*rate).to_i, r, g, b)
        else
          name = "not-tried-lightgray"
        end

        redirect_to "https://img.shields.io/badge/#{name}.svg"
      end

      format.json do
        stats = fills.group(:status).count.transform_keys(&:pluralize).
                reverse_merge(successes: 0, errors: 0, failures: 0)
        render json: stats
      end
    end
  end

  def report_by_date
    fills = Fill.where(status: "success").
            group("date_trunc('day', created_at)").
            order("date_trunc('day', created_at)")

    if params[:bio_id]
      fills = fills.where(bioguide_id: params[:bio_id])
    end

    if params[:campaign_tag]
      fills = fills.where(campaign_tag: params[:campaign_tag])
    end

    render json: fills.count
  end

  def report_by_member
    fills = Fill.where(status: "success").
            group(:bioguide_id).
            order(:bioguide_id)

    if params[:campaign_tag]
      fills = fills.where(campaign_tag: params[:campaign_tag])
    end

    render json: fills.count
  end
end
