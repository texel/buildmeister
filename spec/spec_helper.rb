require 'spec/autorun'
require 'buildmeister'
require 'fakeweb'
require 'timecop'

FakeWeb.allow_net_connect = false

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def load_test_config
  @test_config ||= YAML.load_file(File.dirname(__FILE__) + '/../config/buildmeister_config.sample.yml')
end