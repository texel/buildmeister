require 'spec/autorun'
require 'buildmeister'
require 'fakeweb'

FakeWeb.allow_net_connect = false

Spec::Runner.configure do |config|
  config.mock_with :mocha
end