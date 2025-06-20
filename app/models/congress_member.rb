class CongressMember
  attr_accessor :name, :bioguide_id
  attr_accessor :chamber, :state, :district
  attr_accessor :defunct, :contact_url

  alias_method :defunct?, :defunct

  @@repo = nil
  @@repo_updated_at = nil

  def self.repo
    @@repo
  end

  def self.update_repo
    @@repo =
      begin
        remote = "https://raw.githubusercontent.com/unitedstates/congress-legislators/main/legislators-current.yaml"
        list = YAML.load(RestClient.get(remote))

        @@repo_updated_at = Time.now

        list.map do |item|
          term = item.dig("terms", -1)
          [
            item.dig("id", "bioguide"),
            new(
              name: item.dig("name", "official_full"),
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
    repo[bioguide].try(:tap) do |rep|
      rep.defunct = DefunctCongressForm.find_by(
        bioguide_id: rep.bioguide_id
      ).present?

      return nil if rep.chamber == "house" && ENV["CWC_API_KEY"].blank?
    end
  end

  def self.all
    update_repo if repo_age > 5*60

    defuncts = DefunctCongressForm.all.to_a

    repo.values.sort_by(&:bioguide_id).each do |rep|
      defunct = defuncts.find{ |d| d.bioguide_id == rep.bioguide_id }
      rep.defunct = defunct.present?
    end
  end

  def initialize(name:, bioguide_id:, chamber:, state:,
                 district: nil, contact_url: nil, defunct: false)
    self.name = name
    self.bioguide_id = bioguide_id
    self.chamber = chamber
    self.state = state
    self.district = district
    self.contact_url = contact_url
  end

  def form_id
    if chamber == "senate"
      bioguide_id
    else
      sprintf('H%s%02d', state, district)
    end
  end

  def form
    CongressForms::Form.find(form_id)
  rescue CongressForms::UnsupportedAction => e
    Sentry.capture_exception(e, tags: { bioguide_id: bioguide_id })

    if e.message =~ /recaptcha/i
      DefunctCongressForm.find_or_create_by(bioguide_id: bioguide_id).update(reason: "reCAPTCHA")
    end

    self.defunct = true

    nil
  end
end
