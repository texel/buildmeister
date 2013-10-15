require 'json'

module Lighthouse
  class Account
    attr_accessor :name, :token, :resource

    def initialize(name, token)
      @name  = name
      @token = token

      @url = "https://#{name}.lighthouseapp.com"

      headers = {'X-LighthouseToken' => @token}

      @resource = RestClient::Resource.new(@url, headers: headers)
    end

    def projects
      json = projects_resource.get(accept: 'json')
      response = JSON.parse(json)

      response['projects']
    end

    def find_projects
      
    end

    private

    def projects_resource
      @projects_resource ||= resource['projects']
    end
  end
end
