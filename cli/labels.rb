# frozen_string_literal: true

require "thor"
require "io/console"
require "octokit"

require_relative "github"

dir_path = File.dirname(__FILE__)
pattern = File.join(dir_path, "..", "lib", "**", "*rb")
paths = Dir.glob(pattern)
paths.each { |file| require(file) }

class Samvera::Github::Labels < Samvera::Github

  desc("create", "Create a Label for a Repository")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:name, required: true)
  option(:description)

  def create
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

    label_name = options[:name]
    label_desc = options[:description]
    label_color = options[:color]
    repository.create_label(name: label_name, description: label_desc, color: label_color)
    say("Successfully created the Label #{label_name} for the Repository: #{repository.name}", :green)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
  end

  desc("delete", "Create a Label for a Repository")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:name, required: true)

  def delete
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

    label_name = options[:name]
    repository.delete_label(name: label_name)
    say("Successfully deleted the Label #{label_name} for the Repository: #{repository.name}", :green)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
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
