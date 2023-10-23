# frozen_string_literal: true
require_relative "repository_node"
require_relative "graphql/client"

require "pry-byebug"

module Samvera
  class Project < RepositoryNode
    attr_accessor :body

    def self.where(repository:, **options)
      response_json = repository.client.project(repository.path, **options)
      response_json.map do |object_json|
        build_from_json(repository:, json: response_json)
      end
    rescue Octokit::NotFound
      []
    end

    def graphql_client
      @graphql_client ||= Samvera::GraphQL::Client.new(api_token: client.access_token)
    end

    def create
      return self if persisted?

      graphql_results = graphql_client.create_project(owner_id: owner.node_id, title: name)
      self.node_id = graphql_results["id"]
      self.name = graphql_results["title"]
      @persisted = true
      reload
      #graphql_reload
    end

    def delete
      client.delete_project(id)
      @persisted = false
      self
    end
  end
end
