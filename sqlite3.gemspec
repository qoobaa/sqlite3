# -*- coding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sqlite3"
  s.version = SQLite3::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Jakub Kuźma"]
  s.email = "qoobaa@gmail.com"
  s.homepage = "http://github.com/qoobaa/sqlite3"
  s.summary = "SQLite3 FFI bindings for Ruby 1.9"
  s.description = "Experimental SQLite3 FFI bindings for Ruby 1.9 with encoding support"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "ffi", ">= 0.6.3"
  s.add_development_dependency "test-unit", ">= 2.0"
  s.add_development_dependency "activerecord", ">= 2.3.5"

  s.files = Dir.glob("{lib}/**/*") + %w(LICENSE README.rdoc)

  s.post_install_message = <<-EOM
==== WARNING ===================================================================
This is an early alpha version of SQLite3/Ruby FFI bindings!
Currently we support Ruby 1.9 ONLY.

If you need native bindings for Ruby 1.8 - install sqlite3-ruby instead.
You may need to uninstall this sqlite3 gem as well.

Thank you for installing sqlite3 gem! Suggestions: qoobaa@gmail.com
================================================================================
EOM
end
