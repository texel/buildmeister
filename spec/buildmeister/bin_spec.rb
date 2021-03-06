require 'spec_helper'

describe Buildmeister::Bin do
  let(:ticket_stubs) do
    [stub('ticket_1', :id => 1), stub('ticket_2', :id => 2)]
  end
  
  let(:bin_stub) do
    stub(:tickets => ticket_stubs)
  end
  
  describe "#new" do
    it "should create a new instance" do
      b = Buildmeister::Bin.new(bin_stub)
    end

    it "should default to verbose mode" do
      b = Buildmeister::Bin.new(bin_stub)
      b.mode.should == :verbose
    end
    
    it "should refresh" do
      Buildmeister::Bin.any_instance.expects(:refresh!).once
      b = Buildmeister::Bin.new(bin_stub)
    end
  end
  
  describe "#refresh!" do
    before(:each) do
      @b = Buildmeister::Bin.new(bin_stub)
    end
    
    context "in verbose mode" do
      it "should call tickets" do
        @b.bin.expects(:tickets).once.returns(ticket_stubs)
        @b.refresh!
      end
      
      it "should set value" do
        @b.refresh!
        @b.value.should == '1, 2'
      end
      
      context "after the first refresh" do
        before(:each) do
          @b.value = '1, 2'
        end
        
        it "should set the last value" do
          @b.refresh!
          @b.last_value.should == '1, 2'
        end
      end
    end
    
    context "in quiet mode" do
      before(:each) do
        @b.mode = :quiet
      end
      
      it "should call tickets_count" do
        @b.bin.expects(:tickets_count).once.returns(2)
        @b.refresh!
      end
    end
  end
  
  describe "#changed?" do
    before(:each) do
      @b = Buildmeister::Bin.new(Lighthouse::Bin.new(stub(get: []), {}))
    end
    
    context "with identical values" do
      before(:each) do
        @b.value      = '1, 2'
        @b.last_value = '1, 2'
      end
      
      it "should be false" do
        @b.changed?.should be_false
      end
    end
    
    context "with differing values" do
      before(:each) do
        @b.value      = '1'
        @b.last_value = '1, 2'
      end
      
      it "should be true" do
        @b.changed?.should be_true
      end
    end
  end

  describe "#display" do
    before(:each) do
      @b = Buildmeister::Bin.new(stub(:name => 'The Bin', :tickets => ticket_stubs))
    end
    
    it "displays the ticket" do
      @b.display.should == 'The Bin: 1, 2'
    end
  end
end
