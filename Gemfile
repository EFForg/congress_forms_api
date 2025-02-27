source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem 'rails', '~> 6.1'
gem 'rack', '>= 2.0.8'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use sqlite as the database for tests
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '>= 3.12.2'
gem 'dotenv'
gem 'rack-cors', '>= 1.0.4', require: 'rack/cors'
gem 'nokogiri', '>= 1.10.8'
gem 'loofah', '>= 2.3.1'
gem 'delayed_job_active_record'
gem 'delayed_job_web', '~> 1.4'

gem 'stackprof'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-delayed_job'

gem 'congress_forms', '~> 0.1.14'
gem 'groupdate'
gem 'rubyzip', '>= 1.3.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.18', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-core'
  gem 'rspec-rails', '~> 5.0'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
