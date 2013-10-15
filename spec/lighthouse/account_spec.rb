require 'spec_helper'
require 'json'

describe Lighthouse::Account, :focus => true do
  let(:name) { 'onehub' }
  let(:token) { '12345' }
  let(:account) { Lighthouse::Account.new(name, token) }

  it "should have a resource" do
    account.resource.should_not be_nil
  end

  describe "#projects" do
    let(:projects_response) { File.read('spec/support/projects.json') }

    before do
      account.resource.stubs(:[]).returns(
        stub(:get => projects_response)
      )
    end

    it "should succeed" do
      account.projects
    end
  end
end
