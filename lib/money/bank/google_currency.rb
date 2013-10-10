require 'money'
require 'open-uri'
require 'multi_json'

class Money
  module Bank
    class GoogleCurrency < Money::Bank::VariableExchange

      SERVICE_HOST = "www.google.com"
      SERVICE_PATH = "/ig/calculator"
      EXPONENT_REGEXP = /10(x3c)?sup(x3e)?(?<exponent>-?\d+)(x3c)?\/sup(x3e)?/

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
        expire_rates

        @mutex.synchronize{
          @rates[rate_key_for(from, to)] ||= fetch_rate(from, to)
        }
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
        data = fix_response_json_data(data)

        error = data['error']
        raise UnknownRate unless error == '' || error == '0'
        decode_rate data['rhs']
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
          :query => "hl=en&q=1#{from.iso_code}%3D%3F#{to.iso_code}"
        )
      end

      ##
      # Takes the invalid JSON returned by Google and fixes it.
      #
      # @param [String] data The JSON string to fix.
      #
      # @return [Hash]
      def fix_response_json_data(data)
        data = data.force_encoding("ISO-8859-1").encode("UTF-8")

        data.gsub!(/lhs:/, '"lhs":')
        data.gsub!(/rhs:/, '"rhs":')
        data.gsub!(/error:/, '"error":')
        data.gsub!(/icc:/, '"icc":')
        data.gsub!(Regexp.new("(\\\\x..|\\\\240)"), '')

        MultiJson.decode(data)
      end

      ##
      # Takes the 'rhs' response from Google and decodes it.
      #
      # @param [String] rhs The google rate string to decode.
      #
      # @return [BigDecimal]
      def decode_rate(rhs)
        if complex_rate?(rhs)
          decode_complex_rate(rhs)
        else
          decode_basic_rate(rhs)
        end
      end

      ##
      # Takes the 'rhs' response from Google and decides if it's a complex rate
      #
      # @param [String] rhs The google rate string to check.
      #
      # @return [Boolean]
      def complex_rate?(rhs)
        rhs.match(EXPONENT_REGEXP)
      end

      ##
      # Takes a complex 'rhs' response from Google and converts it to a numeric
      # rate.
      #
      # @param [String] rhs The complex google rate string to convert.
      #
      # @return [BigDecimal]
      def decode_complex_rate(rhs)
        rate  = BigDecimal(rhs.match(/\d[\d\s]*\.?\d*/)[0])
        power = rhs.match(EXPONENT_REGEXP)

        rate * BigDecimal("1E#{power[:exponent]}")
      end

      ##
      # Takes a basic 'rhs' response from Google and converts it to a numeric
      # rate.
      #
      # @param [String] rhs The basic google rate string to convert.
      #
      # @return [BigDecimal]
      def decode_basic_rate(rhs)
        BigDecimal(rhs.gsub(/[^\d\.]/, ''))
      end
    end
  end
end
