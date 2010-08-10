require 'money'
require 'open-uri'

class Money
  module Bank
    class GoogleCurrency < Money::Bank::VariableExchange
      attr_reader :rates

      def get_rate(from, to)
        @mutex.synchronize{
          @rates[rate_key_for(from, to)] ||= get_google_rate(from, to)
        }
      end

      def get_google_rate(from, to)
        data = eval(URI.parse("http://www.google.com/ig/calculator?hl=en&q=1#{from.upcase}%3D%3F#{to.upcase}").read)
        raise UnknownRate unless data[:error] == '' or data[:error] == '0'
        data[:rhs].split(' ')[0].to_f
      end
    end
  end
end
