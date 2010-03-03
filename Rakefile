# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/buildmeister.rb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "buildmeister"
    s.executables = ["buildmeister", "git_cleanup"]
    s.summary = "Dead simple tools for managing Lighthouse and Git deployment workflow"
    s.email = "lcaplan@onehub.com"
    s.homepage = "http://github.com/onehub/buildmeister"
    s.description = "Dead simple tools for managing Lighthouse and Git deployment workflow"
    s.authors = ["Leigh Caplan"]
    s.add_dependency 'lighthouse-api', '>= 1.10'
    s.files =  FileList["[A-Z]*", "{bin,generators,lib,spec}/**/*"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

# vim: syntax=Ruby
