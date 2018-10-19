CongressForms.contact_congress_repository = Rails.root.join("contact_congress").to_s

if ENV["CONTACT_CONGRESS_AUTO_UPDATE"].present?
  value = ENV["CONTACT_CONGRESS_AUTO_UPDATE"]
  CongressForms.auto_update_contact_congress =
    ActiveModel::Type::Boolean.new.cast(value)
end
