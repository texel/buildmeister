module Buildmeister
  class Notifier
    def self.post(title, body)
      `growlnotify -H localhost -s -n "Buildmeister" -d "Buildmeister" -t #{title} -m "#{body}"`
    end
  end
end