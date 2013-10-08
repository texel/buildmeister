require 'spec_helper'

describe Buildmeister::LighthouseClient do
  let(:client) do
    Buildmeister::LighthouseClient.new(account: 'foo', token: 'token')
  end

  describe "#domain" do
    it "should be account-name.lighthouseapp.com" do
      client.domain.should == "foo.lighthouseapp.com"
    end
  end
  
  describe "#protocol" do
    it "should be https://" do
      client.protocol.should == 'https://'
    end
  end
end
