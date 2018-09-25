Rails.application.routes.draw do
  post "retrieve-form-elements", to: "forms#elements"
  post "fill-out-form", to: "forms#fill"
end
