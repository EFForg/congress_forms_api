class Fill < ApplicationRecord
  scope :success, ->{ where(status: "success") }
  scope :campaign, ->(tag){ where(campaign_tag: tag) }

  def self.recent(bio_id)
    form = CongressMember.find(bio_id).form
    where(bioguide_id: bio_id).where("created_at > ?", form.updated_at)
  end

  def success?
    status == "success"
  end

  def error?
    status == "error"
  end

  def failure?
    status == "failure"
  end

  def self.group_by_time(start_date = nil, end_date = nil)
    if start_date.nil? || end_date.nil?
      group_by_day(
        :created_at,
        format: "%b %-e",
      )
    elsif (end_date - start_date) > 5.days
      group_by_day(
        :created_at,
        format: "%b %-e",
        range: start_date..end_date.tomorrow
      )
    else
      group_by_hour(
        :created_at,
        format: "%b %-e, %-l%P",
        range: start_date..end_date.tomorrow
      )
    end
  end
end
