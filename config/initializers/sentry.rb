# frozen_string_literal: true

# https://docs.sentry.io/platforms/ruby/configuration/options/
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  config.environment = ENV['SENTRY_ENVIRONMENT']
  config.enabled_environments = %w[production staging development]

  config.send_default_pii = false

  # https://docs.sentry.io/platforms/ruby/configuration/sampling/
  # A sample rate of 0 or false sends nothing, 1.0 or true sends everything
  config.traces_sampler = lambda do |sampling_context|
    # if this is the continuation of a trace, just use that decision (rate controlled by the caller)
    unless sampling_context[:parent_sampled].nil?
      next sampling_context[:parent_sampled]
    end

    case sampling_context.dig(:env, "HTTP_USER_AGENT")
    when /healthcheck/i
      0.0
    else
      begin ENV['SENTRY_TRACES_SAMPLE_RATE'].to_f rescue 0.0 end
    end
  end

  # Set profiles_sample_rate to profile 100% of sampled transactions.
  # We recommend adjusting this value in production.
  #
  # Does not send profiling info if set to 0
  config.profiles_sample_rate = begin ENV['SENTRY_PROFILES_SAMPLE_RATE'].to_f rescue 0 end
end
