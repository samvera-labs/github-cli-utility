# frozen_string_literal: true

require "thor"
require "io/console"
require "octokit"

require_relative "github"

dir_path = File.dirname(__FILE__)
pattern = File.join(dir_path, "..", "lib", "**", "*rb")
paths = Dir.glob(pattern)
paths.each { |file| require(file) }

class Samvera::Github::Issues < Samvera::Github

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

    issue_number = options[:number]
    issue = repository.find_issue_by(number: issue_number)
    say("Successfully resolved the Pull Request: #{issue.number}", :green)

    comment_body = options[:comment]
    default_options = { event: "COMMENT", body: comment_body }

    issue.create_comment(**default_options)
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

    issue_number = options[:number]
    issue = repository.find_issue_by(number: issue_number)
    say("successfully resolved the pull request: #{issue.number}", :green)

    labels = options[:labels]
    issue.add_labels(labels)
    say("successfully applied the following labels the pull request #{issue.number}: #{labels.join(',')}", :green)
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

    issue_number = options[:number]
    issue = repository.find_issue_by(number: issue_number)
    say("successfully resolved the pull request: #{issue.number}", :green)

    labels = options[:labels]
    issue.remove_labels(labels)
    say("successfully applied the following labels the pull request #{issue.number}: #{labels.join(',')}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end

  desc("assign", "Assign a User or Team for an Issue")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:number, required: true)
  option(:assignees, required: true, type: :array)

  def assign
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

    issue_number = options[:number]
    issue = repository.find_issue_by(number: issue_number)
    say("Successfully resolved the Issue: #{issue.number}", :green)

    assignee_logins = options[:assignees]
    assignees = assignee_logins.map { |login| find_user_or_team_by(organization:, login:) }
    issue.add_assignees(assignees:)
    say("Successfully assigned Issue #{issue_number} to the following: #{assignee_logins.join(',')}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end

  desc("unassign", "Unassign a User or Team for an Issue")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:repo, required: true)
  option(:number, required: true)
  option(:assignees, required: true, type: :array)

  def unassign
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

    issue_number = options[:number]
    issue = repository.find_issue_by(number: issue_number)
    say("Successfully resolved the Issue: #{issue.number}", :green)

    assignee_logins = options[:assignees]
    assignees = assignee_logins.map { |login| find_user_or_team_by(organization:, login:) }
    issue.remove_assignees(assignees:)
    say("Successfully unassigned Issue #{issue_number} from the following: #{assignee_logins.join(',')}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end
end
