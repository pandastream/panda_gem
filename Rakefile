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
    gem.add_dependency "ruby-hmac", ">= 0.3.2"
    gem.add_dependency "rest-client", ">= 1.4"
    gem.add_dependency "json", ">= 1.2"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

desc "Run all the specs"
task :spec do
  system "bundle exec rspec spec"
end

task :default => :spec
