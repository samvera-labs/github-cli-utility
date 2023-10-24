# frozen_string_literal: true

require_relative "owner"

module Samvera
  class Organization < Owner
    attr_accessor :members_url,
                  :public_members_url

    def self.find_by(login:)
      response = client.organizations(**options)
    end

    def self.build_from_octokit(client:, **options)
      response = client.organizations(**options)
      build(client:, values: response)
    end
  end
end
