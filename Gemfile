source "https://rubygems.org"

gem "bootsnap", require: false
gem "clearance", ">= 2.10"
gem "delight"
gem "exid"
gem "importmap-rails"
gem "inertia_rails", "~> 3.9"
gem "jbuilder"
gem "kamal", require: false
gem "propshaft"
gem "puma", ">= 6.0"
gem "rails", ">= 8.0.2"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "sqlite3", ">= 2.1"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 4.2"
# gem "tailwindcss-ruby", "~> 4.1"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "vite_rails", "~> 3.0"

group :development, :test do
  # Recent annotate vem 3.x is locked to old ActiveRecord.
  # https://github.com/ctran/annotate_models/pull/1033

  gem "annotate", github: "tnir/annotate_models", ref: "b4f12a0"
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "foreman", require: false
  gem "pry", require: false
  gem "rubocop", ">= 1.65.0"
  gem "rubocop-capybara"
  gem "rubocop-factory_bot"
  gem "rubocop-performance"
  gem "rubocop-rails", ">= 2.10"
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-thread_safety"
  gem "standard", ">= 1.35.1"
  gem "spring", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda"
  gem "shoulda-matchers"
  gem "test-unit"
end
