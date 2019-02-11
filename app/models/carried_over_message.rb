class CarriedOverMessage < ApplicationRecord
  before_validation :initialize_blank_tags

  serialize :fields
  serialize :tags

  validates_uniqueness_of :job_id

  def submit(submit=true)
    congress_member = CongressMember.find(bioguide_id)

    unless congress_member.present?
      raise ActiveRecord::RecordNotFound,
            "Couldn't find CongressMember<#{bioguide_id}>"
    end

    form = CongressForms::Form.find(congress_member.form_id)

    status = "error"

    begin
      status = if form.fill(fields, submit: submit)
                 "success"
               else
                 "failure"
               end
    rescue CongressForms::Error => e
      self.last_screenshot = e.screenshot.sub(
        Rails.root.join("public").to_s,
        ENV["SERVER_HOST"]
      )

      Raven.capture_exception(
        e,
        message: "#{congress_member.bioguide_id}: #{e.message}",
        tags: {
          "form_error" => true,
          "carry_over" => true,
          "bioguide_id" => congress_member.bioguide_id
        },
        extra: {
          fields: fields,
          screenshot: last_screenshot
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
