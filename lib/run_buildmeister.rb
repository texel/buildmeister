require  File.expand_path(File.dirname(__FILE__) + "/buildmeister")
require 'activesupport'

while true do
  bm    = Buildmeister.new('Macchiato')
  bins  = bm.project.bins

  ready     = bins.find { |bin| bin.name == 'Ready'     }
  staged    = bins.find { |bin| bin.name == 'Staged'    }
  verified  = bins.find { |bin| bin.name == 'Verified'  }

  title = "BuildMeister: #{Time.now.strftime("%m/%d %H:%M %p")}"
  body  = <<-eos
Ready: #{ready.tickets.size}
Staged: #{staged.tickets.size}
Verified: #{verified.tickets.size}
eos

  `growlnotify -s -t "#{title}" -m "#{body}"`
  
  sleep 10.minutes.to_i
end