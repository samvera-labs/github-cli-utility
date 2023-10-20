# frozen_string_literal: true
require_relative "repository_node"

module Samvera
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

    def create
      return self if persisted?

      client.create_project(repository.path, name)
      @persisted = true
      reload
    end

    def delete
      client.delete_project(id)
      @persisted = false
      self
    end
  end
end
