require 'spec_helper'

describe 'Buildmeister::Project' do
  def valid_config
    @valid_config ||= YAML.load_file(File.dirname(__FILE__) + '/../../config/buildmeister_config.sample.yml')['projects'].first
  end
  
  def project_stub
    stub(:name => valid_config['name'], :bins => valid_config['bins'].map { |b| stub(:name => b) })
  end
  
  describe "#new" do
    before(:each) do
      Lighthouse::Project.stubs(:find).returns([project_stub])
      @p = Buildmeister::Project.new(valid_config)
    end
    
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
    
    # it "should set up Buildmeister::Bin objects" do
    #   @p.bins.all? { |b| b.is_a?(Buildmeister::Bin) }.should be_true
    # end
    # 
    # it "should keep bins in order" do
    #   @p.bins.map.should == ['Ready', 'Staged', 'Verified', 'Ready (Experimental)', 'Staged (Experimental)']
    # end
  end

  
end