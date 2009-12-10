module Buildmeister
  module GitUtils
    def new_hotfix
      generate_timed_branch('hotfix')
    end

    def new_experimental
      generate_timed_branch('experimental')
    end

    def generate_timed_branch(prefix)
      branches = local_branches
      now      = Time.now
      count    = 1

      loop do
        new_branch_name = "#{prefix}-#{now.year}-#{now.month.to_s.rjust 2, '0'}-#{now.day.to_s.rjust 2, '0'}-#{count.to_s.rjust 3, '0'}"
        unless branches.include? new_branch_name
          `git checkout -b #{new_branch_name}`
          puts "Created #{new_branch_name}"
          return true
        end

        count += 1
      end
    end

    def pull_bin(bin_name = ARGV.shift)
      raise "Multiple projects are loaded. Please use the -p flag to select one project." if projects.size > 1
      
      project = projects.first
      bin     = project.bins[bin_name]
      
      raise ArgumentError, "#{bin_name} is not a valid bin! Must be in #{project.bins.map(&:name).join(', ')}" unless bin

      `git fetch origin`

      branches        = remote_branches
      ticket_numbers  = bin.tickets.map { |tkt| tkt.id.to_s }

      branches_to_pull = branches.select do |branch_name|
        ticket_numbers.map { |tkt_number| branch_name =~ /#{tkt_number}/ }.any?
      end

      branches_to_pull.each do |branch|
        result = `git pull origin #{branch.gsub("origin/", "")}`
        puts result
      end
    end

    def local_branches
      `git branch`.split.reject { |name| name == "*" }
    end

    def remote_branches
      `git branch -r`.split.reject { |name| name == "*" }
    end

    def current_branch
      branches = `git branch`.split
      i = branches.index "*"
      branches[i + 1]
    end
  end
end