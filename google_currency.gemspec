Gem::Specification.new do |s|
  s.name        = "google_currency"
  s.version     = "3.2.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons"]
  s.email       = ["semmons99@gmail.com"]
  s.homepage    = "http://rubymoney.github.com/google_currency"
  s.summary     = "Access the Google Currency exchange rate data."
  s.description = "GoogleCurrency extends Money::Bank::Base and gives you access to the current Google Currency exchange rates."
  s.license     = 'MIT'

  s.add_development_dependency "rspec", ">= 3.0.0"
  s.add_development_dependency "yard", ">= 0.5.8"
  s.add_development_dependency "ffi"

  s.add_dependency "money", "~> 6.5.0"

  s.files =  Dir.glob("{lib,spec}/**/*")
  s.files += %w(LICENSE README.md CHANGELOG.md AUTHORS)
  s.files += %w(Rakefile .gemtest google_currency.gemspec)

  s.require_path = "lib"
end
