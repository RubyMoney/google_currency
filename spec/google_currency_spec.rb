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
end
