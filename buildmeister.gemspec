# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{buildmeister}
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leigh Caplan"]
  s.date = %q{2009-03-11}
  s.default_executable = %q{buildmeister}
  s.description = %q{FIX (describe your package)}
  s.email = ["lcaplan@onehub.com"]
  s.executables = ["buildmeister", "git_cleanup"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "bin/buildmeister", "bin/git_cleanup", "config/buildmeister_config.sample.yml", "lib/buildmeister.rb", "lib/git_cleanup.rb", "test/test_buildmeister.rb"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{buildmeister}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FIX (describe your package)}
  s.test_files = ["test/test_buildmeister.rb"]

  s.add_dependency('activesupport', [">= 2.0.0"])
  s.add_dependency('texel-lighthouse-api', [">= 1.0.1"])
  
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end
