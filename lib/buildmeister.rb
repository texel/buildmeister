require 'rubygems'
require 'lighthouse'

class Buildmeister
  VERSION = '1.0.0'
  
  attr_accessor :project
  
  def initialize(project_name)
    @config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/config.yml'))
    Lighthouse.account = @config['account']
    Lighthouse.token   = @config['token']
    self.get_project(project_name)
  end
  
  def get_project(project_name)
    projects = Lighthouse::Project.find(:all)
    self.project  = projects.find {|pr| pr.name == project_name}
  end
end