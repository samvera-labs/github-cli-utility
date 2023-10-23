# frozen_string_literal: true
require_relative "repository_node"
require_relative "graphql/client"

require "pry-byebug"

module Samvera
  class Project < RepositoryNode
    attr_accessor :body
    attr_accessor :closed_at
    attr_accessor :created_at
    attr_accessor :database_id
    #attr_accessor :node_id
    #attr_accessor :body
    attr_accessor :resource_path
    attr_accessor :short_description
    attr_accessor :title
    attr_accessor :updated_at

    def self.where(repository:, **options)
      graphql_client = Samvera::GraphQL::Client.new(api_token: repository.client.access_token)
      graphql_nodes = graphql_client.find_projects_by_org(login: repository.owner.login)

      selected = graphql_nodes.select do |graphql_node|
        matches = false
        options.each_pair do |key, value|
          graphql_key = key.to_s
          matches = true if !matches && graphql_node.key?(graphql_key) && graphql_node[graphql_key] == value
        end
        matches
      end

      selected.map do |graphql_node|
        attrs = {}
        attrs["closed_at"] = graphql_node["closedAt"]
        attrs["created_at"] = graphql_node["createdAt"]
        attrs["database_id"] = graphql_node["databaseId"]
        # For consistency with the other models
        attrs["node_id"] = graphql_node["id"]
        attrs["id"] = graphql_node["number"]
        attrs["resource_path"] = graphql_node["resourcePath"]
        attrs["short_description"] = graphql_node["shortDescription"]
        attrs["title"] = graphql_node["title"]
        attrs["updated_at"] = graphql_node["updatedAt"]

        new(repository:, **attrs)
      end

      #binding.pry
      #response_json = repository.client.org_projects(repository.owner.login, **options)
      #response_json.map do |object_json|
      #  build_from_json(repository:, json: response_json)
      #end

      #organization(login: "ORGANIZATION") {
      #projectsV2(first: 20) {
      #  nodes {
      #    id
      #    title
      #  }
      #}
      #}
    rescue Octokit::NotFound
      []
    end

    def graphql_client
      @graphql_client ||= Samvera::GraphQL::Client.new(api_token: client.access_token)
    end

    def create
      return self if persisted?

      graphql_results = graphql_client.create_project(owner_id: owner.node_id, repository_id: repository.node_id, title:)
      self.node_id = graphql_results["id"]
      @persisted = true
      reload
    end

    def delete
      graphql_results = graphql_client.delete_project(project_id: self.node_id)
      @persisted = false
      self
    end
  end
end
