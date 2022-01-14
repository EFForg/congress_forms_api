class ApplicationController < ActionController::API
  rescue_from(ActionController::ParameterMissing) do |e|
    render json: { status: "error", message: e.message }, status: 400
  end

  def not_found
    render json: { status: "error", message: "not found" }, status: 404
  end

  protected

  def check_debug_key
    return unless ENV["DEBUG_KEY"].present?

    a, b = params[:debug_key], ENV["DEBUG_KEY"]

    unless a.present? && ActiveSupport::SecurityUtils.secure_compare(a, b)
      render json: {
        status: "error",
        message: "You must provide a valid debug key to access this endpoint."
      }, status: 401
    end
  end
end
