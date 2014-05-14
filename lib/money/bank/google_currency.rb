require 'money'
require 'open-uri'

class Money
  module Bank
    # Raised when there is an unexpected error in extracting exchange rates
    # from Google Finance Calculator
    class GoogleCurrencyFetchError < Error
    end

    class GoogleCurrency < Money::Bank::VariableExchange


      SERVICE_HOST = "www.google.com"
      SERVICE_PATH = "/finance/converter"

      # @return [Hash] Stores the currently known rates.
      attr_reader :rates


      class << self
        # @return [Integer] Returns the Time To Live (TTL) in seconds.
        attr_reader :ttl_in_seconds

        # @return [Time] Returns the time when the rates expire.
        attr_reader :rates_expiration

        ##
        # Set the Time To Live (TTL) in seconds.
        #
        # @param [Integer] the seconds between an expiration and another.
        def ttl_in_seconds=(value)
          @ttl_in_seconds = value
          refresh_rates_expiration! if ttl_in_seconds
        end

        ##
        # Set the rates expiration TTL seconds from the current time.
        #
        # @return [Time] The next expiration.
        def refresh_rates_expiration!
          @rates_expiration = Time.now + ttl_in_seconds
        end
      end

      ##
      # Clears all rates stored in @rates
      #
      # @return [Hash] The empty @rates Hash.
      #
      # @example
      #   @bank = GoogleCurrency.new  #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_rate(:USD, :EUR)  #=> 0.776337241
      #   @bank.flush_rates           #=> {}
      def flush_rates
        @mutex.synchronize{
          @rates = {}
        }
      end

      ##
      # Clears the specified rate stored in @rates.
      #
      # @param [String, Symbol, Currency] from Currency to convert from (used
      #   for key into @rates).
      # @param [String, Symbol, Currency] to Currency to convert to (used for
      #   key into @rates).
      #
      # @return [Float] The flushed rate.
      #
      # @example
      #   @bank = GoogleCurrency.new    #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_rate(:USD, :EUR)    #=> 0.776337241
      #   @bank.flush_rate(:USD, :EUR)  #=> 0.776337241
      def flush_rate(from, to)
        key = rate_key_for(from, to)
        @mutex.synchronize{
          @rates.delete(key)
        }
      end

      ##
      # Returns the requested rate.
      #
      # It also flushes all the rates when and if they are expired.
      #
      # @param [String, Symbol, Currency] from Currency to convert from
      # @param [String, Symbol, Currency] to Currency to convert to
      #
      # @return [Float] The requested rate.
      #
      # @example
      #   @bank = GoogleCurrency.new  #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_rate(:USD, :EUR)  #=> 0.776337241
      def get_rate(from, to)
        preexpired_rate = @rates[rate_key_for(from, to)]
        expire_rates

        @mutex.synchronize do
          retries = 0
          begin
            return @rates[rate_key_for(from, to)] ||= fetch_rate(from, to)
          rescue OpenURI::HTTPError => e
            retries += 1
            if retries < 3
              retry
            elsif pre_expired_rate
              # We got an error fetching the rate. Re-cache expired rate.
              return @rates[rate_key_for(from, to)] ||= preexpired_rate
            else
              # We couldn't fall back on a cached rate so raise the error
              # after all.
              raise e
            end
          end
        end
      end

      ##
      # Flushes all the rates if they are expired.
      #
      # @return [Boolean]
      def expire_rates
        if self.class.ttl_in_seconds && self.class.rates_expiration <= Time.now
          flush_rates
          self.class.refresh_rates_expiration!
          true
        else
          false
        end
      end

      private

      ##
      # Queries for the requested rate and returns it.
      #
      # @param [String, Symbol, Currency] from Currency to convert from
      # @param [String, Symbol, Currency] to Currency to convert to
      #
      # @return [BigDecimal] The requested rate.
      def fetch_rate(from, to)
        from, to = Currency.wrap(from), Currency.wrap(to)
        data = build_uri(from, to).read
        extract_rate(data)
      end

      ##
      # Build a URI for the given arguments.
      #
      # @param [Currency] from The currency to convert from.
      # @param [Currency] to The currency to convert to.
      #
      # @return [URI::HTTP]
      def build_uri(from, to)
        uri = URI::HTTP.build(
          :host  => SERVICE_HOST,
          :path  => SERVICE_PATH,
          :query => "a=1&from=#{from.iso_code}&to=#{to.iso_code}"
        )
      end

      ##
      # Takes the response from Google and extract the rate.
      #
      # @param [String] data The google rate string to decode.
      #
      # @return [BigDecimal]
      def extract_rate(data)
        case data
        when /<span class=bld>(\d+\.?\d*) [A-Z]{3}<\/span>/
          BigDecimal($1)
        when /Could not convert\./
          raise UnknownRate
        else
          raise GoogleCurrencyFetchError
        end
      end
    end
  end
end
