require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "panda"
    gem.summary = %Q{Panda Client}
    gem.description = %Q{Panda Client}
    gem.email = "info@pandastream.com"
    gem.homepage = "http://github.com/newbamboo/panda_gem"
    gem.authors = ["New Bamboo"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "webmock"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.add_dependency "ruby-hmac", ">= 0.3.2" 
    gem.add_dependency "rest-client", ">= 1.4"
    gem.add_dependency "json", ">= 1.2"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.ruby_opts = ['-rrubygems']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec
