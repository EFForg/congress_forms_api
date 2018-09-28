class CongressFormsFill < ApplicationJob
  def perform(congress_forms_id, fields)
    CongressForms::Form.find(congress_forms_id).fill(fields)
  end

  def reschedule_at(current_time, attempts)
    offset = 5 + attempts ** 4 # delayed_job default
    current_time + [offset, 6.hours].max
  end
end
