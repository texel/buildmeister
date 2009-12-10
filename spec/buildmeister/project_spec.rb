require 'spec_helper'

describe 'Buildmeister::Project' do
  def valid_config
    @valid_config ||= load_test_config['projects'].first
  end
  
  def project_stub
    stub(:name => valid_config['name'], :bins => valid_config['bins'].map { |b| stub({:name => b}) })
  end
  
  before(:each) do
    Lighthouse::Project.stubs(:find).returns([project_stub])
    @p = Buildmeister::Project.new(valid_config)
  end
  
  describe "#new" do    
    it "should create new given a valid config" do
      @p.should be_an_instance_of(Buildmeister::Project)
    end
    
    it "should set the name" do
      @p.name.should == valid_config['name']
    end
    
    it "should set the project" do
      @p.project
    end
    
    it "should set up the appropriate number of bins" do
      @p.should have(valid_config['bins'].size).bins
    end
    
    it "should set up Buildmeister::Bin objects" do
      @p.bins.all? { |b| b.is_a?(Buildmeister::Bin) }.should be_true
    end

    it "should keep bins in order" do
      @p.bins.map(&:name).should == ['Ready', 'Staged', 'Verified', 'Ready (Experimental)', 'Staged (Experimental)']
    end
  end
  
  describe "#changed?" do
    context "with changed bins" do
      before(:each) do
        @p.bins.each { |b| b.stubs(:changed?).returns(true) }
      end
      
      it "should be true" do
        @p.changed?.should be_true
      end
    end
    
    context "with no changed bins" do
      before(:each) do
        @p.bins.each { |b| b.stubs(:changed?).returns(false) }
      end
      
      it "should be false" do
        @p.changed?.should be_false
      end
    end    
  end

  describe "#bins" do
    it "should search using []" do
      @p.bins['Ready'].should be_an_instance_of(Buildmeister::Bin)
    end
  end
  
  describe "#display" do
    it "should display the bins" do
      @p.display.should == <<-STRING_CHEESE
Macchiato
----------
Ready: 
Staged: 
Verified: 
Ready (Experimental): 
Staged (Experimental): 
STRING_CHEESE
    end
  end
end