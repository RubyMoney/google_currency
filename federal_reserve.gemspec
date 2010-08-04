Gem::Specification.new do |s|
  s.name        = "federal_reserve"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons"]
  s.email       = ["semmons99+RubyMoney@gmail.com"]
  s.homepage    = "http://rubymoney.github.com/federal_reserve"
  s.summary     = "Access the Federal Reserve's currency exchange data."
  s.description = "FederalReserve extends Money::Bank::Base and gives you access to the current Federal Reserve of New York's currency exchange rates."

  s.required_rubygems_version = ">= 1.3.7"
  s.rubyforge_project         = "federal_reserve"

  s.add_development_dependency "rspec", ">= 1.3.0"
  s.add_development_dependency "yard", ">= 0.5.8"

  s.add_dependency "money", ">= 3.1.0"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG)
  s.require_path = "lib"
end
