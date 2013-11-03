require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << 'lib/bitmessage'
  t.test_files = FileList['test/lib/bitmessage/*_test.rb']
end

desc "Run tests"
task :default => :test
