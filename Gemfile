source "https://rubygems.org"

gemspec

gem 'jeweler'
gem 'rake'

group :test do
  gem 'rspec', '~> 2'
  gem 'mocha', require: false
  gem 'fakeweb'
  gem 'timecop'
  gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec', '~> 4.0', require: false
end
