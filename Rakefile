# encoding: UTF-8

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sqlite3"
    gem.summary = %Q{SQLite3 FFI bindings for Ruby 1.9}
    gem.description = %Q{SQLite3 FFI bindings for Ruby 1.9}
    gem.email = "qoobaa@gmail.com"
    gem.homepage = "http://github.com/qoobaa/sqlite3"
    gem.authors = ["Jakub Kuźma"]
    gem.add_dependency "ffi", ">= 0.5.1"
    gem.add_development_dependency "test-unit", ">= 2.0"
    gem.add_development_dependency "activerecord", ">= 2.3.5"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.post_install_message = <<-EOM
==== WARNING ===================================================================
This is an early alpha version of SQLite3/Ruby FFI bindings!
Currently we support Ruby 1.9 ONLY.

If you need native bindings for Ruby 1.8 - install sqlite3-ruby instead.
You may need to uninstall this sqlite3 gem as well.

Thank you for installing sqlite3 gem! Suggestions: qoobaa@gmail.com
================================================================================
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sqlite3 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
