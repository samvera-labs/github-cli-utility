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

  desc("add_pull_request", "Add a Pull Request to a Project")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:project, required: true, type: :numeric)
  option(:pull_request, required: true, type: :numeric)
  def add_pull_request
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

    pull_request_number = options[:pull_request]
    pull_request = repository.find_pull_request_by(number: pull_request_number)
    say("successfully resolved the pull request: #{pull_request.number}", :green)

    project_number = options[:project]
    project = repository.project(number: project_number)
    say("Successfully resolved the project: #{project.id}", :green)

    project.add_item(item_node_id: pull_request.node_id)

    say("Successfully added the Pull Request #{pull_request.number} to the Project #{project.title} for the Repository: #{repository.name}", :green)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
  end

  desc("remove_pull_request", "Add a Pull Request to a Project")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:project, required: true, type: :numeric)
  option(:pull_request, required: true, type: :numeric)
  def remove_pull_request
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

    pull_request_number = options[:pull_request]
    pull_request = repository.find_pull_request_by(number: pull_request_number)
    say("successfully resolved the pull request: #{pull_request.number}", :green)

    project_number = options[:project]
    project = repository.project(number: project_number)
    say("Successfully resolved the project: #{project.id}", :green)

    project.remove_pull_request(node_id: pull_request.node_id)

    say("Successfully removed the Pull Request #{pull_request.number} from the Project #{project.title} for the Repository: #{repository.name}", :green)
  rescue Octokit::Unauthorized => authz_error
    say("Error: #{authz_error}", :red)
  end
end
