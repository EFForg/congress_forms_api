class ApplicationController < ActionController::API
  rescue_from(ActionController::ParameterMissing) do |e|
    render json: { status: "error", message: e.message }, status: 400
  end
end
