require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc "Build and release the gem to a private gem server."
task :inabox => :build do
  gemspec_file = Dir.glob("*.gemspec").first or
    raise "Can't locate gem spec."
  spec = Gem::Specification::load(gemspec_file) or
    raise "Failed to load gem spec."
  version = spec.version.to_s or
    raise "Failed to get version string from gem spec."
  gem_file = Dir.glob("pkg/*-#{version}.gem").first or
    raise "Can't locate gem version #{version} in pkg directory."
  sh "gem inabox #{gem_file}"
end
