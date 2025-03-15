# frozen_string_literal: true

require_relative "lib/sqlreport/version"

Gem::Specification.new do |spec|
  spec.name = "sqlreport"
  spec.version = Sqlreport::VERSION
  spec.authors = ["Gem shards"]
  spec.email = ["vincent@gemshards.com"]

  spec.summary = "SQLreport allows you to easily extract data out of a SQL database"
  spec.description = "With SQLreport you can manage query results and convert things."
  spec.homepage = "https://github.com/gem-shards/sqlreport"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.2.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gem-shards/sqlreport"
  spec.metadata["changelog_uri"] = "https://github.com/gem-shards/sqlreport/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "false"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_dependency "railties"
end
