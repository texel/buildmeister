module Buildmeister
  class LighthouseClient
    DEFAULT_DOMAIN = 'lighthouseapp.com'

    def initialize(options = {})
      @account = options[:account]  
      @token   = options[:token]
    end

    def domain
      "#{@account}.#{DEFAULT_DOMAIN}"
    end

    def protocol
      "https://"
    end
  end
end
