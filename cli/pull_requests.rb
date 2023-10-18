# frozen_string_literal: true

require "thor"
require "io/console"
require "octokit"

require_relative "github"

dir_path = File.dirname(__FILE__)
pattern = File.join(dir_path, "..", "lib", "**", "*rb")
paths = Dir.glob(pattern)
paths.each { |file| require(file) }

class Samvera::Github::PullRequests < Samvera::Github

  desc("comment", "Create a Comment for a Pull Request")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:number, required: true)
  option(:comment, required: true)

  def comment
    # Build the client for the GitHub API
    build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

    # This is merely to ensure that the client is authenticated
    user
    say("Successfully authenticated as: #{user}", :green)

    org_login = options[:org]
    organization = find_organization_by!(login: org_login)
    say("Successfully resolved the Organization: #{organization.login}", :green)

    repo_name = options[:repo]
    repository = organization.find_repository_by!(name: repo_name)
    say("Successfully resolved the Repository: #{repository.name}", :green)

    pull_request_number = options[:number]
    pull_request = repository.find_pull_request_by(number: pull_request_number)
    say("Successfully resolved the Pull Request: #{pull_request.number}", :green)

    comment_body = options[:comment]
    default_options = { event: "COMMENT", body: comment_body }

    pull_request.create_pull_request_comment(**default_options)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
  end

  desc("label", "add labels for a pull request")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:number, required: true)
  option(:labels, required: true, type: :array)

  def label
    # build the client for the github api
    build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

    # this is merely to ensure that the client is authenticated
    user
    say("successfully authenticated as: #{user}", :green)

    org_login = options[:org]
    organization = find_organization_by!(login: org_login)
    say("successfully resolved the organization: #{organization.login}", :green)

    repo_name = options[:repo]
    repository = organization.find_repository_by!(name: repo_name)
    say("successfully resolved the repository: #{repository.name}", :green)

    pull_request_number = options[:number]
    pull_request = repository.find_pull_request_by(number: pull_request_number)
    say("successfully resolved the pull request: #{pull_request.number}", :green)

    labels = options[:labels]
    pull_request.add_labels(labels)
    say("successfully applied the following labels the pull request #{pull_request.number}: #{labels.join(',')}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end

  desc("remove_labels", "remove labels for a pull request")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:number, required: true)
  option(:labels, required: true, type: :array)

  def remove_labels
    # build the client for the github api
    build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

    # this is merely to ensure that the client is authenticated
    user
    say("successfully authenticated as: #{user}", :green)

    org_login = options[:org]
    organization = find_organization_by!(login: org_login)
    say("successfully resolved the organization: #{organization.login}", :green)

    repo_name = options[:repo]
    repository = organization.find_repository_by!(name: repo_name)
    say("successfully resolved the repository: #{repository.name}", :green)

    pull_request_number = options[:number]
    pull_request = repository.find_pull_request_by(number: pull_request_number)
    say("successfully resolved the pull request: #{pull_request.number}", :green)

    labels = options[:labels]
    pull_request.remove_labels(labels)
    say("successfully applied the following labels the pull request #{pull_request.number}: #{labels.join(',')}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end



  no_commands do

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def user
      @client
    end

    def session(**options)
      @session ||= Samvera::Session.new(client: @client, **options)
    end

    def organizations(**options)
      session.organizations(**options)
    end

    #def find_organization_by(login:)
    #  session.find_organization_by(login:)
    #end

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
