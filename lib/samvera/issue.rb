# frozen_string_literal: true
module Samvera
  class Issue
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
        attrs.delete(:pull_request)
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
  end
end
