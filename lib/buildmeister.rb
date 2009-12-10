require 'rubygems'
require 'lighthouse'
require 'activesupport'

$: << File.dirname(__FILE__)

require 'buildmeister/string_utils'
require 'buildmeister/git_utils'
require 'buildmeister/finder'
require 'buildmeister/base'
require 'buildmeister/notifier'
require 'buildmeister/project'
require 'buildmeister/bin'