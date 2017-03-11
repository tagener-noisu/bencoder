require 'rake/testtask'

task default: [:test]

task :install do
	`gem build bencoder.gemspec`
	`gem install #{Dir.glob("bencoder*.gem").first} --verbose`
end

task :docs do
	`rdoc --markup markdown README.md lib/*.rb`
end

task :clean do
	puts "cleaning..."
	`rm -rf doc *.gem`
end

Rake::TestTask.new(:test) do |t|
	t.pattern = "test/test_*.rb"
	t.warning = true
end
