$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "spec"
require "federal_reserve"

Spec::Runner.configure do |config|
end
