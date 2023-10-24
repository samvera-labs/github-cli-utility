# frozen_string_literal: true

require_relative "rest/node"

module Samvera
  class Team < REST::Node
    attr_reader :members

    def self.find_by(client:, org:, login:, **attrs)
      response = client.team_by_name(org, login, **attrs)
      build(client:, json: response)
    rescue Octokit::NotFound
      nil
    end

    def initialize(client:, members: [])
      @client = client
      @members = members
    end
  end
end
