# frozen_string_literal: true

require_relative "organization"

module Samvera

  class Session

    def initialize(client:)
      @client = client
    end

    def organizations(**options)
      @organizations ||= Organization.build_from_octokit(client: @client, **options)
    end

    def find_organization_by(login:)
      filtered = organizations.select { |org| org.login == login }
      filtered.first
    end

    def find_user_by(login:)
      User.find_by(client: @client, login:)
    end

    def find_team_by(organization:, login:)
      Team.find_by(client: @client, org: organization, login:)
    end
  end
end
