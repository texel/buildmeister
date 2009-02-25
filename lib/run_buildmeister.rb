require  File.expand_path(File.dirname(__FILE__) + "/buildmeister")
require 'activesupport'

puts "Starting up BuildMeister..."

  bm    = Buildmeister.new('Macchiato')

while true do  
  title = "BuildMeister: #{Time.now.strftime("%m/%d %I:%M %p")}"
  body  = "Ready: #{bm.ready.tickets_count}\nStaged: #{bm.staged.tickets_count}\nVerified: #{bm.verified.tickets_count}"

  puts "Updated notification at #{Time.now.strftime("%m/%d %I:%M %p")}"
  
  if bm.changed?
    `growlnotify -s -n "Lighthouse" -a "Lighthouse" -d 'buildmeister' -t "#{title}" -m "#{body}"`    
  end
  
  sleep 5.minutes.to_i
  
  bm.reload_info
end