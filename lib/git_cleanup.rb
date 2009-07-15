require 'rubygems'
require 'lighthouse'
require 'optparse'
require 'ostruct'
require File.expand_path(File.dirname(__FILE__) + "/../lib/buildmeister")

class GitCleanup

  def initialize
    @config    = Buildmeister.load_config
    Lighthouse.token    = @config['token']
    Lighthouse.account  = @config['account']
    
    @options = {:rules => {}}
    
    OptionParser.new do |opts|
      opts.banner = "Usage: git_cleanup --remote"

      opts.on('-r', '--remote', 'Clean up remote branches') do |f|
        @options[:mode] = 'remote'
      end

      opts.on('-l', '--local', 'Clean up local branches') do
        @options[:mode] = 'local'
      end
      
      opts.on('-t', '--test', 'Test mode - no changes will be made') do
        @options[:test_mode] = true
      end
      
      opts.on('-b', '--before date', 'Automatically delete branches last updated before') do |date|
        @options[:rules].merge!(:before => eval(date))
      end
      
      opts.on('-s', '--state ticket_state', 'Automatically delete branches corresponding to a Lighthouse ticket state') do |state|
        @options[:rules].merge!(:state => state)
      end
      
      opts.on('-m', '--matching string', 'Automatically delete branches with names matching the string') do |string|
        @options[:rules].merge!(:matching => string)
      end
    end.parse!
  end

  def get_project(name)
    projects = Lighthouse::Project.find(:all)
    project  = projects.find {|pr| pr.name == name}
  end

  def prune_these(local_or_remote, branches)
    project = get_project(@config['project_name'])

    branches.each do |branch|
      branch_info = OpenStruct.new(:string => branch, :local_or_remote => local_or_remote)
      
      puts "#{branch_info.string} (updated #{branch_modified(branch_info, :time_ago_in_words)})"

      if project
        get_lighthouse_status(branch_info, project)
        puts branch_info.lighthouse_message
      end
      
      if @options[:rules].empty?
        print "keep [return], delete [d]: "
        user_input = gets
        user_input.strip!

        case user_input
        when 'd'
          send "delete_#{local_or_remote}", branch_info
        end

        puts "\n"
      else
        rules_matched = @options[:rules].map do |rule_name, rule_body|
          send "match_#{rule_name}", branch_info, rule_body
        end

        send "delete_#{local_or_remote}", branch_info if rules_matched.all?
        puts "\n"
      end
    end
  end
  
  def branch_modified(branch_info, format = :time_ago_in_words)      
    format_string =
      case format
      when :time_ago_in_words
        "%ar"
      when :absolute
        "%aD"
      end
      
    `git show #{branch_info.string} --pretty=format:#{format_string}`.split("\n")[0]
  end
  
  # git_cleanup --before 1.month.ago
  def match_before(branch_info, date)
    last_updated = Time.parse(branch_modified(branch_info, :absolute))
    last_updated < date
  rescue
    false
  end
  
  # git_cleanup --state resolved
  def match_state(branch_info, state)
    branch_info.lighthouse_state == state
  end
  
  # git_cleanup --matching hotfix
  def match_matching(branch_info, string)
    branch_info.string =~ /#{string}/
  end

  def delete_local(branch_info)
    execute "git branch -D #{branch_info.string}"
  end

  def delete_remote(branch_info)
    branch_info.string.gsub!(/(remotes\/)|(origin\/)/, '')
    execute "git push origin :#{branch_info.string}", "git remote prune origin"
  end
  
  def execute(*instructions)
    if test_mode?
      puts "Test mode - The following instructions would be executed"
      
      instructions.each do |instruction|
        puts instruction
      end
    else
      instructions.each do |instruction|
        system instruction
      end
    end
  end

  def get_lighthouse_status(branch_info, project)
    lighthouse_id = 
      (matches = branch_info.string.match(/(^|\/)(\d+)-/)) ? matches[2] : nil

    if lighthouse_id
      tickets = project.tickets :q => lighthouse_id
      ticket  = tickets.first
      
      if ticket
        branch_info.lighthouse_state = ticket.state
        branch_info.lighthouse_message = "Lighthouse Info:\nTicket ##{lighthouse_id} state - #{ticket.state}"
        return
      end
    end
    
    branch_info.lighthouse_message = "No Lighthouse Info."
  end

  def cleanup
    branches = `git branch -a`.split.reject { |name| name == "*" }

    local_branches = branches.select do |branch|
      !(branch =~ /^remotes\/origin/)
    end

    remote_branches = branches.select do |branch|
      !local_branches.include?(branch)
    end

    local_or_remote = @options[:mode]

    if local_or_remote == 'local'
      prune_these(local_or_remote, local_branches)
    else
      prune_these(local_or_remote, remote_branches)
    end
  end
  
  def test_mode?
    @options[:test_mode]
  end
end