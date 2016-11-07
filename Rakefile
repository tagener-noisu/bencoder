task default: [:test]

task :install do
	`gem build bencoder.gemspec`
	`gem install #{Dir.glob("bencoder*.gem").first} --verbose`
end

task :test do
	ruby "test/bencoder_test.rb"
end
