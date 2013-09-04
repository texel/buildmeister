# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "buildmeister"
  s.version = "2.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leigh Caplan"]
  s.date = "2013-09-04"
  s.description = "Dead simple tools for managing Lighthouse and Git deployment workflow"
  s.email = "lcaplan@onehub.com"
  s.executables = ["buildmeister", "git_cleanup"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/buildmeister",
    "bin/git_cleanup",
    "lib/buildmeister.rb",
    "lib/buildmeister/base.rb",
    "lib/buildmeister/bin.rb",
    "lib/buildmeister/core_ext.rb",
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
  s.homepage = "http://github.com/onehub/buildmeister"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.6"
  s.summary = "Dead simple tools for managing Lighthouse and Git deployment workflow"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<buildmeister>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.6.7"])
    else
      s.add_dependency(%q<buildmeister>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
    end
  else
    s.add_dependency(%q<buildmeister>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
  end
end

