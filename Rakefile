require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run all the specs"
task :spec do
  system "bundle exec rspec spec"
end

task :default => :spec
