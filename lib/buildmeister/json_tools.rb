require 'json'

module Buildmeister
  module JSONTools
    def with_json_response(json, &block)
      yield JSON.parse(json)
    end
  end
end
