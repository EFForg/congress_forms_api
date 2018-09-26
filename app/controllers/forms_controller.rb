class FormsController < ApplicationController
  def elements
    bio_ids = params.require(:bio_ids)

    es = bio_ids.map{ |id| CongressMember.find(id) }.compact.map do |cm|
      form = CongressForms::Form.find(cm.congress_forms_id)

      fields = form.required_params.tap do |fields|
        fields.each do |f|
          f[:maxlength] = f.delete(:max_length)
          f[:options_hash] = f.delete(:options)
        end
      end

      [
        cm.bioguide_id,
        { required_actions: fields }
      ]
    end

    render json: es.to_h
  end

  def fill
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

  rescue_from(ActionController::ParameterMissing) do |e|
    render json: { status: "error", message: e.message }, status: 400
  end
end
