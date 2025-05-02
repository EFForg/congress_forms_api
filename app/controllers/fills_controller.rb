class FillsController < ApplicationController
  include ActionController::MimeResponds

  before_action :check_debug_key,
                only: %w(index report_by_date report_by_member)

  before_action :find_form, only: :create
  before_action :check_for_missing_fields, only: :create

  def create
    fields = params.require(:fields).permit!.to_h

    begin
      status =
        if @form.fill(fields, validate_only: params[:test] == "1")
          "success"
        else
          # @TODO: report to sentry?
          "failure"
        end
    rescue CongressForms::Error => e
      Sentry.capture_exception(
        CongressFormsApi::FillError.new(e.message, @congress_member.bioguide_id),
        tags: {
          "form_error" => true,
          "bioguide_id" => @congress_member.bioguide_id
        },
        extra: {
          field_keys: fields&.keys,
        }
      )

      deprecation = DefunctCongressForm.find_or_create_by(bioguide_id: @congress_member.bioguide_id)
      deprecation.update(reason: e.message)
    ensure
      Fill.create(
        bioguide_id: @congress_member.bioguide_id,
        campaign_tag: params[:campaign_tag],
        status: status || "error"
      )
    end

    render json: { status: "success" }
  end

  def index
    fills = Fill.campaign(params[:campaign_tag])

    if params[:all_statuses]
      fills = fills.where(bioguide_id: params[:bio_id])
    else
      fills = fills.recent(params[:bio_id])
    end

    # @TODO: can we expose this endpoint to action center to get fill status
    # reported there?
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
    if params[:date_start] && params[:date_end]
      start_date = Time.zone.parse(params[:date_start])
      end_date = Time.zone.parse(params[:date_end])
    end

    fills = Fill.campaign(params[:campaign_tag]).
      where(status: "success").
      group_by_time(start_date, end_date)

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

    report = fills.count.transform_keys do |bioguide|
      CongressMember.find(bioguide).try(:name) || bioguide
    end

    render json: report
  end

  protected

  def find_form
    bio_id = params.require(:bio_id)

    if @congress_member = CongressMember.find(bio_id)
      @form = @congress_member.form
    else
      # @TODO: send to sentry?
      render json: {
               status: "error",
               message: "Congress member with provided bio id not found"
             }.to_json
    end
  end

  def check_for_missing_fields
    fields = params.require(:fields).permit!.to_h

    if missing_params = @form.missing_required_params(fields)
      # @TODO: send to sentry?
      # careful about sending field content to sentry
      message = "Error: missing fields (#{missing_params.join(', ')})."
      render json: { status: "error", message: message }.to_json
    end
  end
end
