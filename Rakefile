require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError => e
  task "spec" do
    puts "RSpec not loaded - make sure it's installed and you're using bundle exec"
    exit 1
  end
end

task :default => :spec
