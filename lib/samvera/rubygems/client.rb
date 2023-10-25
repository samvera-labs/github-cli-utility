# frozen_string_literal: true

require_relative "gem"
require "faraday"

module Samvera
  module RubyGems
    class Client

      def self.default_uri
        URI("https://rubygems.org/api/v1/")
      end

      def initialize(api_key:, mfa: false, uri: nil, otp: nil)
        @api_key = api_key
        @uri = if uri.nil?
                 self.class.default_uri
               else
                 URI(uri)
               end

        @mfa = mfa
        @otp = otp

        @http_client = Faraday.new(url: @uri.to_s, headers: build_headers)
      end

      def build_headers
        built = {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Authorization" => @api_key
        }
        built["OTP"] = @otp if mfa?
        built
      end

      def mfa?
        @mfa
      end

      def execute_delete_request(path:, **params)
        response = @http_client.delete(path, **params)
        raise_http_error(response:) unless response.success?

        response
      end

      def execute_post_request(path:, **params)
        params_json = JSON.generate(params)
        response = @http_client.post(path, params_json)
        raise_http_error(response:) unless response.success?

        response
      end

      def execute_get_request(path:)
        response = @http_client.get(path)
        raise_http_error(response:) unless response.success?

        response
      end

      # `Index rubygems` scope must be enabled for the RubyGems API key
      def gems
        path = "gems.json"
        response = execute_get_request(path:)
        built = Gem.build_all_from_response(client: self, response:)
        built
      end

      # `Index rubygems` scope must be enabled for the RubyGems API key
      def find_gem_by(name:)
        path = "gems/#{name}.json"
        response = execute_get_request(path:)
        built = Gem.build_from_response(client: self, response:)
        built
      end

      # `Index rubygems` scope must be enabled for the RubyGems API key
      def find_owners_by(gem_name:)
        path = "gems/#{gem_name}/owners.json"
        response = execute_get_request(path:)
        built = User.build_all_from_response(client: self, response:)
        built
      end

      private

      def raise_http_error(response:)
        case response.status
        when 401, 403
          raise(StandardError, "Not authorized to #{response.env.method} request for #{response.env.url}: #{response.body}")
        when 404
          raise(StandardError, "HTTP resource #{response.env.url} could not be found.")
        else
          raise(StandardError, "Error #{response.status} transmitting #{response.env.method} request for #{response.env.url}: #{response.body}")
        end
      end
    end
  end
end
