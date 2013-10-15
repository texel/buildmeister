Bundler.require(:default, :test)
require 'rspec/autorun'
require 'buildmeister'
require 'fakeweb'
require 'timecop'
require 'mocha/api'

FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.mock_with :mocha
  config.filter_run :focus => true  
  config.run_all_when_everything_filtered = true
end

def load_test_config
  @test_config ||= YAML.load_file(File.dirname(__FILE__) + '/../config/buildmeister_config.sample.yml')
end
