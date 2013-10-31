require 'timecop'

RSpec.configure do |config|
end

def load_rate_http_response(name)
  f = File.expand_path("../rates/#{name}.html", __FILE__)
  File.read(f, :encoding => 'iso-8859-1')
end
