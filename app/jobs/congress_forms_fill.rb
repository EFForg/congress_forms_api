class CongressFormsFill < ApplicationJob
  def perform(congress_forms_id, fields)
    CongressForms::Form.find(congress_forms_id).fill(fields)
  end
end
