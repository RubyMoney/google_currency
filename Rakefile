require 'rubygems'
require 'rake'
require 'rake/clean'

CLOBBER.include('.yardoc', 'doc', '*.gem')

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:test) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort 'YARD is not available. In order to run yardoc, you must: sudo gem install yard'\
  end
end
