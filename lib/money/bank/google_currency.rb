require 'money'
require 'open-uri'

class Money
  module Bank
    class GoogleCurrency < Money::Bank::VariableExchange
      attr_reader :rates

      def flush_rates
        @mutex.synchronize{
          @rates = {}
        }
      end

      def get_rate(from, to)
        @mutex.synchronize{
          @rates[rate_key_for(from, to)] ||= get_google_rate(from, to)
        }
      end

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
