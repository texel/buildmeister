require 'spec_helper'

describe Lighthouse::Bin do
  let(:resource) { stub() }
  let(:bin) do
    Lighthouse::Bin.new(resource, 'name' => 'Bin', 'id' => 1234, 'query' => 'state: resolved', 'tickets_count' => 4)
  end

  it "should have a name" do
    bin.name.should == 'Bin'
  end

  it "should have an id" do
    bin.id.should == 1234
  end

  it "should have a query" do
    bin.query.should == 'state: resolved'
  end

  it "should have tickets_count" do
    bin.tickets_count.should == 4
  end

  describe "#tickets" do
    it "should be implemented"
  end
end
