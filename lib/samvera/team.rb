# frozen_string_literal: true

require_relative "rest/node"

module Samvera
  class Team < REST::Node
    attr_reader :members
    attr_accessor :created_at,
                  :description,
                  :html_url,
                  :members_count,
                  :members_url,
                  :name,
                  :notification_setting,
                  :organization,
                  :parent,
                  :permission,
                  :persisted,
                  :privacy,
                  :repos_count,
                  :repositories_url,
                  :slug,
                  :updated_at

    # @param client [Octokit::Client]
    # @param response [Sawyer::Resource]
    def self.build_from_response(client:, response:)
      attrs = response.to_hash
      attrs.delete(:organization)

      new(client:, **attrs)
    end

    def self.find_by(client:, org:, login:, **attrs)
      response = client.team_by_name(org.login, login, **attrs)
      build_from_response(client:, response:)
    rescue Octokit::NotFound
      nil
    end

    def initialize(client:, members: [], **attributes)
      @client = client
      @members = members

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end
    end

    def add_user(user:, **options)
      @client.add_team_member(id, user.login, **options)
    end

    def remove_user(user:, **options)
      @client.remove_team_member(id, user.login, **options)
    end
  end
end
