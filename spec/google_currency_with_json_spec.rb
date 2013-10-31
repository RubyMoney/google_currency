require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'money'
require 'money/bank/google_currency'

describe "GoogleCurrency" do
  before :each do
    @bank = Money::Bank::GoogleCurrency.new
  end

  it "should accept a ttl_in_seconds option" do
    Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
    Money::Bank::GoogleCurrency.ttl_in_seconds.should eql(86400)
  end

  describe ".refresh_rates_expiration!" do
    it "set the #rates_expiration using the TTL and the current time" do
      Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
      new_time = Time.now
      Timecop.freeze(new_time)
      Money::Bank::GoogleCurrency.refresh_rates_expiration!
      Money::Bank::GoogleCurrency.rates_expiration.should eql(new_time + 86400)
    end
  end

  describe "#get_rate" do
    it "should try to expire the rates" do
      @bank.should_receive(:expire_rates).once
      @bank.get_rate('USD', 'USD')
    end

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

    context "handles" do
      before :each do
        @uri = double('uri')
        @bank.stub(:build_uri){ |from,to| @uri }
      end

      it "should return rate when it is known" do
        @uri.stub(:read) { load_rate_http_response("sgd_to_usd") }
        @bank.get_rate('SGD', 'USD').should == BigDecimal("0.8066")
      end

      it "should raise UnknownRate error when rate is not known" do
        @uri.stub(:read) { load_rate_http_response("vnd_to_usd") }
        expect {
          @bank.get_rate('VND', 'USD')
        }.to raise_error(Money::Bank::UnknownRate)
      end

      it "should raise GoogleCurrencyFetchError there is an unknown issue with extracting the exchange rate" do
        @uri.stub(:read) { load_rate_http_response("error") }
        expect {
          @bank.get_rate('VND', 'USD')
        }.to raise_error(Money::Bank::GoogleCurrencyFetchError)
      end
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

  describe "#expire_rates" do
    before do
      Money::Bank::GoogleCurrency.ttl_in_seconds = 1000
    end

    context "when the ttl has expired" do
      before do
        new_time = Time.now + 1001
        Timecop.freeze(new_time)
      end

      it "should flush all rates" do
        @bank.should_receive(:flush_rates)
        @bank.expire_rates
      end

      it "updates the next expiration time" do
        exp_time = Time.now + 1000

        @bank.expire_rates
        Money::Bank::GoogleCurrency.rates_expiration.should eql(exp_time)
      end
    end

    context "when the ttl has not expired" do
      it "not should flush all rates" do
        @bank.should_not_receive(:flush_rates)
        @bank.expire_rates
      end
    end
  end
end
