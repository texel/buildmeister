# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{buildmeister}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Leigh Caplan}]
  s.date = %q{2012-07-06}
  s.description = %q{Dead simple tools for managing Lighthouse and Git deployment workflow}
  s.email = %q{lcaplan@onehub.com}
  s.executables = [%q{buildmeister}, %q{git_cleanup}]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "History.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/buildmeister",
    "bin/git_cleanup",
    "lib/buildmeister.rb",
    "lib/buildmeister/base.rb",
    "lib/buildmeister/bin.rb",
    "lib/buildmeister/finder.rb",
    "lib/buildmeister/git_utils.rb",
    "lib/buildmeister/notifier.rb",
    "lib/buildmeister/project.rb",
    "lib/buildmeister/string_utils.rb",
    "lib/git_cleanup.rb",
    "spec/buildmeister/base_spec.rb",
    "spec/buildmeister/bin_spec.rb",
    "spec/buildmeister/project_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/onehub/buildmeister}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Dead simple tools for managing Lighthouse and Git deployment workflow}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<lighthouse-api>, ["~> 2.0"])
    else
      s.add_dependency(%q<lighthouse-api>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<lighthouse-api>, ["~> 2.0"])
  end
end

