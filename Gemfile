source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.12'

gem 'bootstrap', '~> 4.3.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem "ransack"

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# used by CareersPageParser/Processor
gem 'colorize'
gem 'final_redirect_url'
gem 'down'

gem 'hashie'
gem 'nokogiri'
gem 'selenium-webdriver', '3.14.0'
###

gem 'kaminari'
gem 'bootstrap4-kaminari-views'
gem 'lever_postings'
gem 'sidekiq'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'webmock'
end

group :test do
  gem 'shoulda-matchers'
end

group :development do
  gem 'dotenv-rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
