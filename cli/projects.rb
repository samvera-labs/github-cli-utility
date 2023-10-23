# frozen_string_literal: true

require "thor"
require "io/console"
require "octokit"

require_relative "github"

dir_path = File.dirname(__FILE__)
pattern = File.join(dir_path, "..", "lib", "**", "*rb")
paths = Dir.glob(pattern)
paths.each { |file| require(file) }

class Samvera::Github::Projects < Samvera::Github

  desc("create", "Create a Project for a Repository")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:title, required: true)
  option(:body)

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

    project_title = options[:title]
    project_body = options[:body]

    repository.create_project(title: project_title, body: project_body)
    say("Successfully created the Project #{project_title} for the Repository: #{repository.name}", :green)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
  end

  desc("delete", "Create a Project for a Repository")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:title, required: true)

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

    project_title = options[:title]

    repository.delete_project(title: project_title)
    say("Successfully deleted the Project #{project_title} for the Repository: #{repository.name}", :green)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
  end
end
