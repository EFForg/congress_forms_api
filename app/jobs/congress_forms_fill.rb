class CongressFormsFill < ApplicationJob
  def perform(bioguide_id, fields)
    CongressMember.find(bioguide_id).form.fill(fields)
  end

  def reschedule_at(current_time, attempts)
    # @TODO: decrease attempts? send to sentry here?
    offset = 5 + attempts ** 4 # delayed_job default
    current_time + [offset, 6.hours].max
  end
end
