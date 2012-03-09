require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run all the specs"
task :spec do
  exec "bundle exec rspec spec"
end

task :default => :spec
