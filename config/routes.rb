Rails.application.routes.draw do
  post "retrieve-form-elements", to: "congress_members#form_actions"
  post "fill-out-form", to: "fills#create"

  get "recent-fill-image/:bio_id",
      to: "fills#report", defaults: { format: "svg" }
  get "recent-fill-status/:bio_id",
      to: "fills#report", defaults: { format: "json" }

  get "recent-statuses-detailed/:bio_id",
      to: "fills#index"

  get "successful-fills-by-date/:bio_id", to: "fills#report_by_date"
  get "successful-fills-by-member", to: "fills#report_by_member"

  get "list-actions/:bio_id", to: "congress_members#index_actions"
  get "list-congress-members", to: "congress_members#index"
end
