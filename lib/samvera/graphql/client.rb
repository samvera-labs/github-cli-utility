# frozen_string_literal: true

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

      def initialize(api_token:, context: {}, schema_cached: nil, uri: nil, schema_uri: nil)
        @api_token = api_token
        @context = {}
        @uri = uri || self.class.default_uri
        @schema_uri = schema_uri || self.class.default_schema_uri
        if schema_cached.nil?
          @schema_cached = File.exist?(schema_json_file)
        else
          @schema_cached = schema_cached
        end
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

      def schema_cached?
        @schema_cached
      end

      def schema_json_file
        File.join(__dir__, "schema.json")
      end

      def schema_cache
        File.read(schema_json_file)
      end

      def update_schema_cache(json:)
        fh = File.open(schema_json_file, "wb")
        fh.write(json)
        fh.close
        @schema_cached = true
        schema_json_file
      end

      def schema_json
        parsed = if schema_cached?
                   JSON.parse(schema_cache)
        else
          update_schema_cache(json: schema_response)
          JSON.parse(schema_response)
        end

        parsed
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
end
