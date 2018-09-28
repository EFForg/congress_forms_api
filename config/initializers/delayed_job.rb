if [ENV["ADMIN_USER_NAME"], ENV["ADMIN_PASSWORD"]].all?(&:present?)
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV["ADMIN_USER_NAME"]) &&
      ActiveSupport::SecurityUtils.secure_compare(password, ENV["ADMIN_PASSWORD"])
  end
end

Delayed::Worker.destroy_failed_jobs = false

