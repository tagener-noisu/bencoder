require 'rake/testtask'

task default: [:test]

task :install do
	`gem build bencoder.gemspec`
	`gem install #{Dir.glob("bencoder*.gem").first} --verbose`
end

task :docs do
	`rdoc README.md lib/*.rb`
end

Rake::TestTask.new(:test) do |t|
	t.pattern = "test/*.rb"
	t.warning = true
end