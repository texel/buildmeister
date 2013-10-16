require 'spec_helper'
require 'json'

describe Lighthouse::Account do
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

  describe "#find_projects" do
    let(:projects) do 
      [stub(:name => 'Project1'), stub(:name => 'Project2'), stub(:name => 'Project3')]
    end

    before { account.stubs(:projects).returns(projects) }

    it "should find the correct projects" do
      result = account.find_projects('Project1', 'Project3')
      result.length.should == 2
    end
  end
end
