require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'money'
require 'money/bank/google_currency'

## require one of the JSON libraries supported by MultiJson
require 'json'
# require 'yajl'

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

    it "should work for Currency.wrap(:USD)->Currency.wrap(:USD)" do
      @bank.get_google_rate(Money::Currency.wrap(:USD),
                            Money::Currency.wrap(:USD)).should == 1.0
    end

    it "should raise an UnknownCurrency error for an unknown currency" do
      lambda{@bank.get_google_rate('USD', 'BATMAN')}.should raise_error(Money::Currency::UnknownCurrency)
    end

    it "should raise and UnknownRate error for a known currency but unknown rate" do
      lambda{@bank.get_google_rate('USD', 'ALL')}.should raise_error(Money::Bank::UnknownRate)
    end
  end

  describe "#get_rate" do
    it "should use #fetch_rate when rate is unknown" do
      @bank.should_receive(:fetch_rate).once
      @bank.get_rate('USD', 'USD')
    end

    it "should not use #fetch_rate when rate is known" do
      @bank.get_rate('USD', 'USD')
      @bank.should_not_receive(:fetch_rate)
      @bank.get_rate('USD', 'USD')
    end

    it "should return the correct rate" do
      @bank.get_rate('USD', 'USD').should == 1.0
    end

    it "should store the rate for faster retreival" do
      @bank.get_rate('USD', 'EUR')
      @bank.rates.should include('USD_TO_EUR')
    end
  end

  describe "#flush_rates" do
    it "should empty @rates" do
      @bank.get_rate('USD', 'EUR')
      @bank.flush_rates
      @bank.rates.should == {}
    end
  end

  describe "#flush_rate" do
    it "should remove a specific rate from @rates" do
      @bank.get_rate('USD', 'EUR')
      @bank.get_rate('USD', 'JPY')
      @bank.flush_rate('USD', 'EUR')
      @bank.rates.should include('USD_TO_JPY')
      @bank.rates.should_not include('USD_TO_EUR')
    end
  end
end
