# frozen_string_literal: true

module Samvera
  module RubyGems
    class Resource

      def self.build_all_from_response(client:, response:)
        parsed = JSON.parse(response.body)
        built = parsed.map do |attributes|
          new(client:, **attributes)
        end
        built
      end

      def self.build_from_response(client:, response:)
        attributes = JSON.parse(response.body)
        new(client:, **attributes)
      end

      def initialize(client:, **attributes)
        @client = client

        #require 'pry-byebug'
        #binding.pry
        attributes.each do |key, value|
          signature = "#{key}="
          self.public_send(signature, value)
        end
      end
    end
  end
end
