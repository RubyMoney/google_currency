require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'money'
require 'money/bank/google_currency'

require 'yajl'
MultiJson.engine = :yajl

describe "GoogleCurrency" do
  before :each do
    @bank = Money::Bank::GoogleCurrency.new
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
