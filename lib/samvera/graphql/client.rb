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

      def build_schema_request
        request = Net::HTTP::Get.new(@uri)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "bearer #{@api_token}"
        request
      end

      def schema_response
        request = build_schema_request
        http.connection.request(request)
      end

      def build_graphql_request(query:, variables: nil, operation_name: nil)
        request = Net::HTTP::Post.new(@uri)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "bearer #{@api_token}"

        body = {}
        body["query"] = query
        body["variables"] = variables unless variables.nil?
        body["operationName"] = operation_name unless operation_name.nil?
        request.body = JSON.generate(body)

        request
      end

      def execute_graphql_query(query:, variables: nil)
        request = build_graphql_request(query:, variables:)
        response = http.connection.request(request)
        # Errors at the level of the HTTP
        raise(StandardError, "HTTP error encountered: #{response.body}") if response.code != "200"
        parsed = JSON.parse(response.body)
        # Errors within the GraphQL query (these return a 200 status code)
        if parsed.key?("errors")
          errors = parsed["errors"].map { |error| error["message"] }.join(" ")
          raise(StandardError, "GraphQL API error encountered: #{errors}")
        end

        response_data = parsed["data"]
        response_data
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
        <<-GRAPHQL
          mutation($ownerId: ID!, $title: String!, $repositoryId: ID!) {
            createProjectV2(input: { ownerId: $ownerId, title: $title, repositoryId: $repositoryId }) {
              projectV2 {
                id
                title
              }
            }
          }
        GRAPHQL
      end

      def create_project(owner_id:, title:, repository_id:)
        variables = {
          ownerId: owner_id,
          title:,
          repositoryId: repository_id
        }
        results = execute_graphql_query(query: create_project_mutation, variables:)
        # {"createProjectV2"=>{"projectV2"=>{"id"=>"PVT_kwDOBV7-Ic4AXONV", "title"=>"test3"}}
        create_project_v2 = results["createProjectV2"]
        project_v2 = create_project_v2["projectV2"]
        project_v2
      end
    end
  end
end
