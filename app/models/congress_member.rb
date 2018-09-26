class CongressMember
  attr_accessor :bioguide_id, :chamber, :state, :district, :contact_url

  @@repo = nil
  @@repo_updated_at = nil

  def self.repo
    @@repo
  end

  def self.update_repo
    @@repo =
      begin
        remote = "https://raw.githubusercontent.com/unitedstates/congress-legislators/master/legislators-current.yaml"
        list = YAML.load(RestClient.get(remote))

        @@repo_updated_at = Time.now

        list.map do |item|
          term = item.dig("terms", -1)
          [
            item.dig("id", "bioguide"),
            new(
              bioguide_id: item.dig("id", "bioguide"),
              chamber: term["type"] == "sen" ? "senate" : "house",
              state: term["state"],
              district: term["district"],
              contact_url: term["contact_form"] || term["url"]
            )
          ]
        end.to_h
      rescue RestClient::Exception => e
        @@repo
      end
  end

  def self.repo_age
    @@repo_updated_at ? (Time.now - @@repo_updated_at) : Float::INFINITY
  end

  def self.find(bioguide)
    update_repo if repo_age > 5*60
    repo[bioguide]
  end

  def self.all
    update_repo if repo_age > 5*60
    repo.values.sort_by(&:bioguide_id)
  end

  def initialize(bioguide_id:, chamber:, state:,
                 district: nil, contact_url: nil)
    self.bioguide_id = bioguide_id
    self.chamber = chamber
    self.state = state
    self.district = district
    self.contact_url = contact_url
  end

  def congress_forms_id
    if chamber == "senate"
      bioguide_id
    else
      sprintf('H%s%02d', state, district)
    end
  end
end
