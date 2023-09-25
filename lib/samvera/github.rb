# frozen_string_literal: true
require "thor"
require "io/console"
require "octokit"

module Samvera
  class Github < Thor
    attr_reader :client_id, :login

    desc("auth", "Authenticate")
    option(:netrc, type: :boolean)
    option(:client_id)
    option(:login)
    def auth
      # Build the client for the GitHub API
      build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

      # This is merely to ensure that the client is authenticated
      user
      say("Successfully authenticated as: #{user}", :green)
    rescue Octokit::Unauthorized => authz_error
      say("Error: #{authz_error}", :red)
    end

    desc("orgs", "Organizations")
    option(:netrc, type: :boolean)
    option(:client_id)
    option(:login)

    def orgs
      # Build the client for the GitHub API
      build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

      # This is merely to ensure that the client is authenticated
      user
      say("Successfully authenticated as: #{user}", :green)

      organizations.each do |org|
        say("Organization: #{org.login}", :green)
      end
    rescue Octokit::Unauthorized => authz_error
      say("Error: #{authz_error}", :red)
    end

    desc("repos", "Repositories")
    option(:netrc, type: :boolean)
    option(:client_id)
    option(:login)

    option(:org, default: "samvera")
    def repos
      # Build the client for the GitHub API
      build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

      # This is merely to ensure that the client is authenticated
      user
      say("Successfully authenticated as: #{user}", :green)

      org_login = options[:org]
      organization = find_organization_by(login: org_login)
      say("Successfully resolved the Organization: #{organization.login}", :green)

      organization.repositories.each do |repo|
        say("Repository: #{repo.name}", :green)
      end
    rescue Octokit::Unauthorized => authz_error
      say("Error: #{authz_error}", :red)
    end

    desc("issues", "Issues")
    option(:netrc, type: :boolean)
    option(:client_id)
    option(:login)

    option(:org, default: "samvera")
    option(:repo, required: true)
    def issues
      # Build the client for the GitHub API
      build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

      # This is merely to ensure that the client is authenticated
      user
      say("Successfully authenticated as: #{user}", :green)

      org_login = options[:org]
      organization = find_organization_by(login: org_login)
      say("Successfully resolved the Organization: #{organization.login}", :green)

      repo_name = options[:repo]
      repository = organization.find_repository_by(name: repo_name)
      say("Successfully resolved the Repository: #{repository.name}", :green)

      repository.issues.each do |issue|
        say("Issue: #{issue.html_url}", :green)
      end
    rescue Octokit::Unauthorized => authz_error
      say("Error: #{authz_error}", :red)
    end

    no_commands do

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
            attrs.delete(:user)
            attrs.delete(:labels)
            attrs.delete(:pull_request)
            attrs.delete(:reactions)

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
      end

      class Organization
        attr_reader :client
        attr_accessor :avatar_url,
                      :description,
                      :events_url,
                      :hooks_url,
                      :id,
                      :issues_url,
                      :login,
                      :members_url,
                      :node_id,
                      :public_members_url,
                      :repos_url,
                      :url

        def self.build_from_hash(client:, values:)
          values.map do |org_json|
            new(client:, **org_json)
          end
        end

        def initialize(client:, **attributes)
          @client = client

          attributes.each do |key, value|
            signature = "#{key}="
            self.public_send(signature, value)
          end
        end

        def repositories(**options)
          response = @client.organization_repositories(login, **options)
          Repository.build_from_hash(owner: self, values: response)
        end

        def find_repository_by(name:, **options)
          all = repositories(**options)
          filtered = all.select { |repo| repo.name == name }
          filtered.first
        end
      end

      ####

      # `delegate` triggers strange behavior within Thor::CLI Classes
      def user
        @client
      end

      def organizations(**options)
        response = user.organizations(**options)
        Organization.build_from_hash(client: user, values: response)
      end

      def find_organization_by(login:)
        filtered = organizations.select { |org| org.login == login }
        filtered.first
      end

      def access_token
        @access_token ||= STDIN.getpass("Please enter your GitHub API personal access token:")
      end

      def password
        @password ||= STDIN.getpass("Please enter your GitHub user password:")
      end

      def client_id
        @client_id ||= STDIN.getpass("Please enter your GitHub API client ID:")
      end

      def client_secret
        @client_secret ||= STDIN.getpass("Please enter your GitHub API client secret:")
      end

      def client_with_access_token
        @client ||= Octokit::Client.new(access_token:)
      end

      def client_with_secret
        @client ||= Octokit::Client.new(client_id:, client_secret:)
      end

      def client_with_password
        @client ||= Octokit::Client.new(login:, password:)
      end

      def client_with_netrc
        @client ||= Octokit::Client.new(netrc: true)
      end

      def build_client(netrc: nil, client_id: nil, login: nil)
        if netrc
          client_with_netrc
        else
          @client_id = client_id
          @login = login

          if @client_id
            client_with_secret
          elsif @login
            client_with_password
          else
            client_with_access_token
          end
        end
      end
    end
  end
end
