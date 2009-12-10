require 'spec_helper'

describe 'Buildmeister::Project' do
  def valid_config
    YAML.load_file(File.dirname(__FILE__) + '/../config.yml')['projects'].first
  end
  
  describe "#new" do
    before(:each) do
      @p = Buildmeister::Project.new(valid_config)
    end
    
    it "should create new given a valid config" do
      @p.should be_an_instance_of(Buildmeister::Project)
    end
    
    it "should set the name" do
      @p.name.should == valid_config['name']
    end
    
    it "should set up the appropriate number of bins" do
      @p.should have(valid_config['bins'].size).bins
    end
    
    it "should keep bins in order" do
      @p.bins.map.should == ['Ready', 'Staged', 'Verified', 'Ready (Experimental)', 'Staged (Experimental)']
    end
  end

  
end