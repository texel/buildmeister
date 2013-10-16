require 'json'

module Buildmeister
  module JSONUtils
    def with_json_response(json, &block)
      yield JSON.parse(json)
    end
  end
end
