require  File.expand_path(File.dirname(__FILE__) + "/buildmeister")
require 'activesupport'

puts "Starting up BuildMeister..."

while true do
  bm    = Buildmeister.new('Macchiato')
  bins  = bm.project.bins

  ready     = bins.find { |bin| bin.name == 'Ready'     }
  staged    = bins.find { |bin| bin.name == 'Staged'    }
  verified  = bins.find { |bin| bin.name == 'Verified'  }

  title = "BuildMeister: #{Time.now.strftime("%m/%d %I:%M %p")}"
  body  = "Ready: #{ready.tickets.size}\nStaged: #{staged.tickets.size}\nVerified: #{verified.tickets.size}"

  puts "Updated notification at #{Time.now.strftime("%m/%d %I:%M %p")}"

  `growlnotify -s -n "Lighthouse" -a "Lighthouse" -d 'buildmeister' -t "#{title}" -m "#{body}"`
  
  sleep 10.minutes.to_i
end