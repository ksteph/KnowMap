source 'https://rubygems.org'

gem 'rails', '3.2.8'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'                                # Postgres
gem 'jquery-rails'                      # jQuery
gem "bcrypt-ruby", :require => "bcrypt" # encryption library
gem 'dynamic_form'                      # helpers for error messages in forms
gem 'cancan'                            # Authorization
gem 'paper_trail'                       # Active Record Versioning
gem "rufus-scheduler", "~> 2.0.17"      # Background Task Scheduler

group :test do
  gem 'cucumber-rails', :require => false
  gem 'cucumber-rails-training-wheels'
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
end

group :development, :test do
  gem "rspec-rails", "~> 2.0"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby
  gem 'uglifier', '>= 1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
