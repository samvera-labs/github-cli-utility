# frozen_string_literal: true
require_relative "repository_node"

require "graphql/client"
require "graphql/client/http"

require "pry-byebug"

module Samvera
  module GraphQL

    class Client
      def self.default_uri
        "https://api.github.com/graphql"
      end

      def self.default_schema_uri
        "https://docs.github.com/public/schema.docs.graphql"
      end

      def initialize(api_token:, context: {}, uri: nil, schema_uri: nil)
        @api_token = api_token
        @context = {}
        @uri = uri || self.class.default_uri
        @schema_uri = schema_uri || self.class.default_schema_uri
      end

      def http
        @http ||= ::GraphQL::Client::HTTP.new(@uri) do
          def headers(context)
            [
              "Authorization: bearer #{context['api_token']}"
            ]
          end
        end
      end

      def schema_request
        request = Net::HTTP::Get.new(@uri)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "bearer #{@api_token}"
        request
      end

      def schema_response
        response = http.connection.request(schema_request)
        response.body
      end

      def schema_json
        JSON.parse(schema_response)
      end

      def schema
        @schema ||= ::GraphQL::Client.load_schema(schema_json)
      end

      def client
        @client ||= ::GraphQL::Client.new(schema:, execute: http)
      end

      # ProjectInput {
      #   ownerId: "OWNER_ID",
      #   title: "PROJECT_NAME"
      # }
      def create_project_mutation
        client.parse <<-GRAPHQL
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

      def create_project(owner_id:, title:)
        # result = SWAPI::Client.query(Hero::HeroFromEpisodeQuery, variables: {episode: "JEDI"}, context: {user_id: current_user_id})
        variables = {
          ownerId: owner_id,
          title:
        }
        client.query(create_project_mutation, variables:, context: @context)
      end
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

    def graphql_client
      @graphql_client ||= Samvera::GraphQL::Client.new(api_token: client.access_token)
    end

    def create
      return self if persisted?

      graphql_client.create_project(owner_id: owner.id, title: name)
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
