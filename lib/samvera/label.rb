# frozen_string_literal: true

require_relative "repository/node"

module Samvera
  class Label < Repository::Node
    attr_accessor :color,
                  :default,
                  :description

    def self.build_from_json(repository:, json:)
      attrs = json.to_hash
      # These were persisted within the GitHub API
      attrs[:persisted] = true

      new(repository:, **attrs)
    end

    def self.find_by(repository:, name:, **options)
      response_json = repository.client.label(repository.path, name, **options)
      build_from_json(repository:, json: response_json)
    rescue Octokit::NotFound
      nil
    end

    def self.find_or_create_by(repository:, **attrs)
      persisted = find_by(repository:, **attrs)
      return persisted unless persisted.nil?

      built = new(repository:, **attrs)
      built.create
    end

    def initialize(repository:, **attributes)
      @repository = repository

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end

      @persisted ||= false
    end

    def persisted?
      @persisted
    end

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def owner
      repository.owner
    end

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def client
      owner.client
    end

    def reload
      self.class.find_by(repository:, name:)
    end

    def create
      return self if persisted?

      create_args = if color.nil?
                      [repository.path, name]
      else
        [repository.path, name, color]
      end
      client.add_label(*create_args)
      @persisted = true
      reload
    end

    def delete
      client.delete_label!(repository.path, name)
      @persisted = false
      self
    end
  end
end
