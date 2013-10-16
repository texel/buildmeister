require 'json'

module Lighthouse
  class Account
    include Buildmeister::JSONUtils

    attr_accessor :name, :token, :resource

    def initialize(name, token)
      @name  = name
      @token = token

      @url = "https://#{name}.lighthouseapp.com"

      @resource = create_resource(@url, @token)
    end

    def projects
      with_json_response( projects_resource.get(accept: 'json') ) do |response|
        response['projects'].map do |p|
          attrs = p['project']
          id    = attrs['id']

          Lighthouse::Project.new(resource["projects/#{id}"], attrs)
        end.tap { |p| p.extend Buildmeister::Finder }
      end
    end

    def find_projects(*names)
      projects.select { |p| names.include?(p.name) }
    end

    private

    def projects_resource
      @projects_resource ||= resource['projects']
    end

    def create_resource(url, token)
      headers = {'X-LighthouseToken' => token}

      RestClient::Resource.new(url, headers: headers)
    end
  end
end
