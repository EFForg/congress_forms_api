class CongressMembersController < ApplicationController
  before_action :check_debug_key, only: %w(index index_actions)

  def form_actions
    bio_ids = params.require(:bio_ids)

    es = bio_ids.map{ |id| CongressMember.find(id) }.map do |cm|
      if form = cm.try(:form)
        fields = form.required_params.tap do |fields|
          fields.each do |f|
            f[:maxlength] = f.delete(:max_length)
            f[:options_hash] = f.delete(:options)
          end
        end
      else
        fields = []
      end

      [
        cm.bioguide_id,
        { required_actions: fields,
          defunct: cm.defunct?,
          contact_url: cm.contact_url }
      ]
    end.compact

    render json: es.to_h
  end

  def index
    render json: CongressMember.all
  end

  def index_actions
    f = CongressMember.find(params[:bio_id]).form

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
