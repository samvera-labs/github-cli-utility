# frozen_string_literal: true
require_relative "repository_node"
require_relative "graphql/client"

module Samvera
  class Project < RepositoryNode
    attr_accessor :body
    attr_accessor :closed_at
    attr_accessor :created_at
    attr_accessor :database_id
    attr_accessor :items
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

        items = graphql_node["items"]
        item_nodes = items["nodes"]
        attrs["items"] = item_nodes

        new(repository:, **attrs)
      end
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

    def add_item(item_node_id:)
      graphql_client.add_project_item(project_id: self.node_id, item_id: item_node_id)
    end

    def find_item_id_for(node_id:)
      selected = items.select { |item| item["content"]["id"] == node_id }
      return if selected.empty?

      item = selected.first
      item["id"]
    end

    def remove_pull_request(node_id:)
      item_node_id = find_item_id_for(node_id:)
      graphql_client.delete_project_item(project_id: self.node_id, item_id: item_node_id)
    end

    def delete
      graphql_results = graphql_client.delete_project(project_id: self.node_id)
      @persisted = false
      self
    end
  end
end
