class CongressMembersController < ApplicationController
  def index
    # todo
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
