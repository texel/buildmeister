require 'spec_helper'

describe Buildmeister::Base do
  before(:each) do
    Buildmeister::Base.stubs(:load_config).returns(load_test_config)
    @project_stub = stub(:name => 'Project', :bins => [stub(), stub()])
    Buildmeister::Project.stubs(:new).returns(@project_stub)
  end  
  
  describe '#new' do
    it "should create a new instance" do
      b = Buildmeister::Base.new
      b.should be_an_instance_of(Buildmeister::Base)
    end
    
    it "should set quiet mode if passed -q" do
      b = Buildmeister::Base.new('-q')
      b.instance_variable_get(:@options)[:mode].should == :quiet
    end
    
    it "should set move_from if passed -f" do
      b = Buildmeister::Base.new('-f', 'Cool Bin')
      b.instance_variable_get(:@options)[:move_from].should == 'Cool Bin'
    end
    
    it "should set to_state if passed -t" do
      b = Buildmeister::Base.new('-t', 'staged')
      b.instance_variable_get(:@options)[:to_state].should == 'staged'
    end
    
    context "passed the -p flag" do
      before(:each) do
        @b = Buildmeister::Base.new('-p', 'Macchiato')
      end
      
      it "should set the project" do
        @b.instance_variable_get(:@options)[:project].should == 'Macchiato'
      end
      
      it "should only load the specified project" do
        @b.projects.size.should == 1
      end
    end

    
    it "should set the Lighthouse account from config" do
      config = load_test_config
      b = Buildmeister::Base.new
      Lighthouse.account.should == config['account']
    end
    
    it "should set the Lighthouse token from config" do
      config = load_test_config
      b = Buildmeister::Base.new
      Lighthouse.token.should == config['token']
    end
    
    it "should set up the projects" do
      b = Buildmeister::Base.new
      b.projects.should == [@project_stub, @project_stub]
    end
    
    it "should set the notification interval" do
      b = Buildmeister::Base.new
      b.notification_interval.should == 3
    end
  end
  
  describe "#changed?" do
    context "with changed bins" do
      before(:each) do
        @project_stub = stub(:changed? => true)
        Buildmeister::Project.stubs(:new).returns(@project_stub)
      end
      
      it "should be true" do
        b = Buildmeister::Base.new
        b.changed?.should be_true
      end
    end
  end
  
  describe "#projects" do
    before(:each) do
      @project_stub = stub(:name => 'Project', :bins => [stub(), stub()])
      Buildmeister::Project.stubs(:new).returns(@project_stub)
    end
    
    it "should search using []" do
      b = Buildmeister::Base.new
      b.projects['Project'].should == @project_stub
    end
  end

  describe "title" do
    it "should look like this" do
      Timecop.freeze(Time.parse('1/1/2010 9am')) do
        b = Buildmeister::Base.new
        b.title.should == 'Buildmeister: 01/01 09:00 AM'
      end
    end
  end
  
  describe "#divider" do
    before(:each) do
      @b = Buildmeister::Base.new
    end
    
    it "looks like this by default" do
      @b.divider.should == "----------"
    end
    
    it "accepts character and size arguments" do
      @b.divider("=", 5).should == '====='
    end
  end
  
  
end
