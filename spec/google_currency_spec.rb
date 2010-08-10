require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'money'
require 'money/bank/google_currency'

describe "GoogleCurrency" do
  before :each do
    @bank = Money::Bank::GoogleCurrency.new
  end

  describe "#get_google_rate" do
    it "should work for USD->USD" do
      @bank.get_google_rate('USD', 'USD').should == 1.0
    end

    it "should work for usd->usd" do
      @bank.get_google_rate('usd', 'usd').should == 1.0
    end

    it "should raise an UnknownRate error for an invalid currency" do
      lambda{@bank.get_google_rate('USD', 'BATMAN')}.should raise_error Money::Bank::UnknownRate
    end
  end

  describe "#get_rate" do
    it "should use #get_google_rate when rate is unknown" do
      @bank.should_receive(:get_google_rate).once
      @bank.get_rate('USD', 'USD')
    end

    it "should not use #get_google_rate when rate is known" do
      @bank.get_rate('USD', 'USD')
      @bank.should_not_receive(:get_google_rate)
      @bank.get_rate('USD', 'USD')
    end

    it "should return the correct rate" do
      @bank.get_rate('USD', 'USD').should == 1.0
    end
  end
end
