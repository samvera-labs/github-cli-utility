# frozen_string_literal: true

require_relative "repository"

module Samvera
  class Organization
    attr_reader :client
    attr_accessor :avatar_url,
      :description,
      :events_url,
      :hooks_url,
      :id,
      :issues_url,
      :login,
      :members_url,
      :node_id,
      :public_members_url,
      :repos_url,
      :url

    def self.build(client:, values:)
      values.map do |org_json|
        new(client:, **org_json)
      end
    end

    def self.build_from_octokit(client:, **options)
      response = client.organizations(**options)
      build(client:, values: response)
    end

    def initialize(client:, **attributes)
      @client = client

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end
    end

    def repositories(**options)
      response = @client.organization_repositories(login, **options)
      Repository.build_from_hash(owner: self, values: response)
    end

    def find_repository_by(name:, **options)
      all = repositories(**options)
      filtered = all.select { |repo| repo.name == name }
      filtered.first
    end

    def find_repository_by!(name:, **options)
      repository = find_repository_by(name:, **options)
      return repository unless repository.nil?

      error_message = "Failed to resolve the Repository: #{name}"
      raise(StandardError, error_message)
    end
  end
end
