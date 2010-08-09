require 'money'
require 'open-uri'

class Money
  module Bank
    class GoogleCurrency < Money::Bank::VariableExchange
      def get_rate(from, to)
        data = eval(URI.parse("http://www.google.com/ig/calculator?hl=en&q=1#{from.upcase}%3D%3F#{to.upcase}").read)
        raise UnknownRate unless data[:error] == '' or data[:error] == '0'
        data[:rhs].split(' ')[0].to_f
      end
    end
  end
end
