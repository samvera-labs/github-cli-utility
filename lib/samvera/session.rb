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
  end
end
