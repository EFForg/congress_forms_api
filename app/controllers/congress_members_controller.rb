class CongressMembersController < ApplicationController
  def form_actions
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

  def index
    render json: CongressMember.all
  end

  def index_actions
    f = CongressForms::Form.find(params[:bio_id])

    actions = f.actions.each_with_index.map do |action, i|
      {
        step: i + 1,
        action: action.class.name.underscore.split("/")[-1],
        selector: action.selector,
        value: action.value,
        required: action.required?,
        maxlength: action.max_length,
        options: action.options
      }
    end

    render json: { actions: actions }
  end
end
