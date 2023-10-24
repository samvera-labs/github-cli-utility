# frozen_string_literal: true

require_relative "repository/node"

module Samvera
  class Issue < Repository::Node
    attr_accessor :active_lock_reason,
                  :assignee,
                  :assignees,
                  :author_association,
                  :body,
                  :closed_at,
                  :comments,
                  :comments_url,
                  :created_at,
                  :draft,
                  :events_url,
                  :html_url,
                  :id,
                  :labels_url,
                  :locked,
                  :milestone,
                  :node_id,
                  :number,
                  :performed_via_github_app,
                  :pull_request,
                  :repository_url,
                  :state,
                  :state_reason,
                  :timeline_url,
                  :title,
                  :updated_at,
                  :url

    def self.build_from_hash(owner:, repository:, values:)
      values.map do |repo_json|
        attrs = repo_json.to_hash
        attrs.delete(:labels)
        attrs.delete(:reactions)
        attrs.delete(:user)

        new(owner:, repository:, **attrs)
      end
    end

    def initialize(owner:, repository:, **attributes)
      @owner = owner
      @repository = repository

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end
    end

    # https://docs.github.com/en/graphql/reference/mutations#addassigneestoassignable
    # https://docs.github.com/en/graphql/reference/input-objects#addassigneestoassignableinput
    def add_assignees(assignees:)
      assignee_ids = assignees.map { |a| a.node_id }
      graphql_client.add_assignees(node_id: self.node_id, assignee_ids:)
    end

    # https://docs.github.com/en/graphql/reference/mutations#removeassigneesfromassignable
    # https://docs.github.com/en/graphql/reference/input-objects#removeassigneesfromassignableinput
    def remove_assignees(assignees:)
      assignee_ids = assignees.map { |a| a.node_id }
      graphql_client.remove_assignees(node_id: self.node_id, assignee_ids:)
    end
  end
end
