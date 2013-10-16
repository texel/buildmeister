require 'spec_helper'

describe Lighthouse::Project do
  let(:resource) { stub(:[] => stub) } 
  let(:attributes) do
    {'id' => '123', 'name' => 'Project'}
  end
  let(:project) do
    Lighthouse::Project.new(resource, attributes)
  end
  
  describe "#new" do    
    it "should create new given a valid config" do
      project.should be_an_instance_of(Lighthouse::Project)
    end

    it "should set the name" do
      project.name.should == attributes['name']
    end

    it "should set the id" do
      project.id.should == attributes['id']
    end

    it "should set the resource" do
      project.resource.should == resource
    end
  end

  describe "#bins" do
    let(:bins_response) do
      File.read('spec/support/bins.json')
    end

    before { project.stubs(:bins_resource).returns(stub(:get => bins_response)) }

    it "should succeed" do
      project.bins
    end

    it "should list the bins" do
      bin = project.bins.first
      bin.class.should == Lighthouse::Bin
    end
  end
  
  describe "#tickets" do
    let(:tickets_response) do
      File.read('spec/support/tickets.json')
    end

    before { project.stubs(:tickets_resource).returns(stub(:get => tickets_response)) }

    it "should succeed" do
      project.tickets
    end

    it "should list the tickets" do
      project.tickets.all? { |t| t.is_a?(Lighthouse::Ticket) }.should be_true
    end
  end

  describe "#find_tickets" do
    it "should be implemented"
  end
end
