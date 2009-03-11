# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/buildmeister.rb'

Hoe.new('buildmeister', Buildmeister::VERSION) do |p|
  p.rubyforge_name = 'buildmeister' # if different than lowercase project name
  p.developer('Leigh Caplan', 'lcaplan@onehub.com')
end

task :cultivate do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end

# vim: syntax=Ruby
