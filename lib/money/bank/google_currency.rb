require 'money'
require 'open-uri'

class Money
  module Bank
    class GoogleCurrency < Money::Bank::VariableExchange
      # @return [Hash] Stores the currently known rates.
      attr_reader :rates

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
      # Returns the requested rate from @rates if it exists, otherwise calls
      # +#get_google_rate+.
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
        @mutex.synchronize{
          @rates[rate_key_for(from, to)] ||= get_google_rate(from, to)
        }
      end

      ##
      # Returns the requested rate after querying Google.
      #
      #
      # @param [String, Symbol, Currency] from Currency to convert from
      # @param [String, Symbol, Currency] to Currency to convert to
      #
      # @return [Float] The requested rate.
      #
      # @example
      #   @bank = GoogleCurrency.new         #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_google_rate(:USD, :EUR)  #=> 0.776337241
      def get_google_rate(from, to)
        from = Currency.wrap(from)
        to   = Currency.wrap(to)

        data = URI.parse("http://www.google.com/ig/calculator?hl=en&q=1#{from.iso_code}%3D%3F#{to.iso_code}").read
        data.gsub!(/lhs:/, ':lhs =>')
        data.gsub!(/rhs:/, ':rhs =>')
        data.gsub!(/error:/, ':error =>')
        data.gsub!(/icc:/, ':icc =>')
        data = eval(data)

        raise UnknownRate unless data[:error] == '' or data[:error] == '0'
        data[:rhs].split(' ')[0].to_f
      end
    end
  end
end
