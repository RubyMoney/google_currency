require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'money'
require 'money/bank/google_currency'

describe "GoogleCurrency" do
  before :each do
    @bank = Money::Bank::GoogleCurrency.new
  end

  describe "#google_rate_for" do
    it "should work for USD->USD" do
      @bank.google_rate_for('USD', 'USD').should == 1.0
    end

    it "should work for usd->usd" do
      @bank.google_rate_for('usd', 'usd').should == 1.0
    end

    it "should raise an UnknownRate error for an invalid currency" do
      lambda{@bank.google_rate_for('USD', 'BATMAN')}.should raise_error Money::Bank::UnknownRate
    end
  end
end
