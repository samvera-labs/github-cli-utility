# frozen_string_literal: true
require_relative "repository_node"

module Samvera
  class GraphQlClient

    def create_project

    end

  end

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

    def graphql_schema
      Samvera::GraphQL::Schema
    end

    #input: {
    #  ownerId: "OWNER_ID",
    #  title: "PROJECT_NAME"
    #}
    def graphql_create_mutation
      <<-GRAPHQL
mutation {
  createProjectV2($input: ProjectInput!) {
    projectV2 {
      id
      title
    }
  }
}
      GRAPHQL
    end

    def graphql_create_project(owner_id:, title:)
      variables = {
        "owner_id": owner_id,
        "title": title
      }

      graphql_schema.execute(graphql_create_mutation, variables:)
    end

    def create
      return self if persisted?

      #client.create_project(repository.path, name)
      graphql_create_project(graphql_create_mutation)
      #graphql_client.create_project(repository.path, name)
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
