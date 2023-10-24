# frozen_string_literal: true

require_relative "../rest/node"
require_relative "client"

module Samvera
  module GraphQL
    class Node < REST::Node

      def self.build_graphql_client(api_token:)
        built = Samvera::GraphQL::Client.new(api_token:)
        built
      end

      def self.find_children_by(parent:, client_method:, client_method_args:, **attrs)
        graphql_client = build_graphql_client(api_token: parent.access_token)
        graphql_nodes = graphql_client.send(client_method, **client_method_args)

        selected = graphql_nodes.select do |graphql_node|
          matches = false
          attrs.each_pair do |key, value|
            graphql_key = key.to_s
            matches = true if !matches && graphql_node.key?(graphql_key) && graphql_node[graphql_key] == value
          end
          matches
        end

        selected
      end

      def self.where(parent:, **attrs)
        selected = find_children_by(parent:, client_method:, client_method_args:, **attrs)
        selected.map do |new_attrs|
          new(**new_attrs)
        end
      end

      def graphql_client
        @graphql_client ||= Samvera::GraphQL::Client.new(api_token: client.access_token)
      end
    end
  end
end
