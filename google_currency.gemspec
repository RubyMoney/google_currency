Gem::Specification.new do |s|
  s.name        = "google_currency"
  s.version     = "1.2.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons", "Donald Ball"]
  s.email       = ["semmons99+RubyMoney@gmail.com", "donald.ball@gmail.com"]
  s.homepage    = "http://rubymoney.github.com/google_currency"
  s.summary     = "Access the Google Currency exchange rate data."
  s.description = "GoogleCurrency extends Money::Bank::Base and gives you access to the current Google Currency exchange rates."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "yard", ">= 0.5.8"

  s.add_dependency "money", "~> 3.5"
  s.add_dependency "multi_json", ">= 1.0.0"

  s.files =  Dir.glob("{lib,spec}/**/*")
  s.files += %w(LICENSE README.md CHANGELOG.md)
  s.files += %w(Rakefile .gemtest google_currency.gemspec)

  s.require_path = "lib"
end
