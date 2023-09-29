# frozen_string_literal: true
module Samvera
  class PullRequest
    attr_accessor :active_lock_reason,
                  :assignee,
                  :assignees,
                  :author_association,
                  :auto_merge,
                  :base,
                  :body,
                  :closed_at,
                  :comments_url,
                  :commits_url,
                  :created_at,
                  :diff_url,
                  :draft,
                  :head,
                  :html_url,
                  :id,
                  :issue_url,
                  :labels,
                  :locked,
                  :merge_commit_sha,
                  :merged_at,
                  :milestone,
                  :node_id,
                  :number,
                  :patch_url,
                  :requested_reviewers,
                  :requested_teams,
                  :review_comment_url,
                  :review_comments_url,
                  :state,
                  :statuses_url,
                  :title,
                  :updated_at,
                  :url

    def self.build_from_hash(owner:, repository:, values:)
      values.map do |repo_json|
        attrs = repo_json.to_hash
        attrs.delete(:_links)
        attrs.delete(:base)
        attrs.delete(:head)
        attrs.delete(:labels)
        attrs.delete(:repo)
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

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def client
      owner.client
    end

    def create_pull_request_comment(body:, **options)
      client.create_pull_request_comment(@repository.name, number, body, **options)
    end
  end
end
