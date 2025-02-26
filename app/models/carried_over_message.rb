class CarriedOverMessage < ApplicationRecord
  before_validation :initialize_blank_tags

  serialize :fields
  serialize :tags

  validates_uniqueness_of :job_id

  def submit(validate_only: false)
    congress_member = CongressMember.find(bioguide_id)

    unless congress_member.present?
      raise ActiveRecord::RecordNotFound,
            "Couldn't find CongressMember<#{bioguide_id}>"
    end

    status = "error"

    begin
      status = if congress_member.form.fill(fields, validate_only: validate_only)
                 "success"
               else
                 "failure"
               end
    rescue CongressForms::Error => e
      Sentry.capture_exception(
        CongressFormsApi::FillError.new(e.message, congress_member.bioguide_id),
        tags: {
          "form_error" => true,
          "carry_over" => true,
          "bioguide_id" => congress_member.bioguide_id
        },
        extra: {
          field_keys: fields&.keys,
        }
      )
    ensure
      increment!(:attempts)
      touch(:last_attempted_at)
      update!(
        last_attempted_at: Time.now,
        last_status: status,
        complete: complete || (status == "success")
      )
    end
  end

  private

  def initialize_blank_tags
    self.tags = [] if tags.blank?
  end
end
