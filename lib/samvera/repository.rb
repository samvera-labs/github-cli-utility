# frozen_string_literal: true
require_relative "issue"
require_relative "pull_request"

module Samvera
  class Repository
    attr_reader :owner
    attr_accessor :allow_forking,
      :archive_url,
      :archived,
      :assignees_url,
      :blobs_url,
      :branches_url,
      :clone_url,
      :collaborators_url,
      :comments_url,
      :commits_url,
      :compare_url,
      :contents_url,
      :contributors_url,
      :created_at,
      :default_branch,
      :deployments_url,
      :description,
      :disabled,
      :downloads_url,
      :events_url,
      :fork,
      :forks,
      :forks_count,
      :forks_url,
      :full_name,
      :git_commits_url,
      :git_refs_url,
      :git_tags_url,
      :git_url,
      :has_discussions,
      :has_downloads,
      :has_issues,
      :has_pages,
      :has_projects,
      :has_wiki,
      :homepage,
      :hooks_url,
      :html_url,
      :id,
      :is_template,
      :issue_comment_url,
      :issue_events_url,
      :issues_url,
      :keys_url,
      :labels_url,
      :language,
      :languages_url,
      :license,
      :merges_url,
      :milestones_url,
      :mirror_url,
      :name,
      :node_id,
      :notifications_url,
      :open_issues,
      :open_issues_count,
      :private,
      :pulls_url,
      :pushed_at,
      :releases_url,
      :security_and_analysis,
      :size,
      :ssh_url,
      :stargazers_count,
      :stargazers_url,
      :statuses_url,
      :subscribers_url,
      :subscription_url,
      :svn_url,
      :tags_url,
      :teams_url,
      :topics,
      :trees_url,
      :updated_at,
      :url,
      :visibility,
      :watchers,
      :watchers_count,
      :web_commit_signoff_required

    def self.build_from_hash(owner:, values:)
      values.map do |repo_json|
        attrs = repo_json.to_hash
        attrs.delete(:license)
        attrs.delete(:owner)
        attrs.delete(:permissions)
        attrs.delete(:security_and_analysis)

        new(owner:, **attrs)
      end
    end

    def initialize(owner:, **attributes)
      @owner = owner

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end
    end

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def client
      owner.client
    end

    def issues(**options)
      base = "#{owner.login}/#{name}"
      response = client.list_issues(base, **options)

      Issue.build_from_hash(owner:, repository: self, values: response)
    end

    def pull_requests(**options)
      base = "#{owner.login}/#{name}"
      response = client.pull_requests(base, **options)

      PullRequest.build_from_hash(owner:, repository: self, values: response)
    end

    def find_pull_request_by(number:, **options)
      #base = "#{owner.login}/#{name}"
      #@client.pull(@test_repo, @pull.number)
      #response = client.pull(base, number)
      #attrs = response.to_hash
      #PullRequest.new(owner: owner, repository: self, **attrs)

      all = pull_requests(**options)
      filtered = all.select { |repo| repo.number == number.to_i }
      filtered.first
    end
  end
end
