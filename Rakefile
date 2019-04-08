require 'rdoc/task'
require 'rake/clean'
require 'rake/testtask'

include Rake

desc "Run unit tests"
TestTask.new do |t|
	t.test_files = FileList["test/test-*.rb"]
    t.verbose = true
end

desc "Run only tests"
task :default => [:test]
