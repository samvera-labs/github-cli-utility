# frozen_string_literal: true

require "thor"
require "io/console"

require_relative "github"

dir_path = File.dirname(__FILE__)
pattern = File.join(dir_path, "..", "lib", "**", "*rb")
paths = Dir.glob(pattern)
paths.each { |file| require(file) }

class Samvera::Github::Teams < Samvera::Github

  desc("add_user", "Add a User to a Team")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:team, required: true)
  option(:user, required: true)

  def add_user
    # build the client for the github api
    build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

    # this is merely to ensure that the client is authenticated
    user
    say("Successfully authenticated as: #{user}", :green)

    org_login = options[:org]
    organization = find_organization_by!(login: org_login)
    say("Successfully resolved the Organization: #{organization.login}", :green)

    team_login = options[:team]
    team = find_team_by(organization:, login: team_login)
    say("Successfully resolved the Team: #{team.name}", :green)

    user_login = options[:user]
    user = find_user_by(login: user_login)

    team.add_user(user:)

    say("Successfully added the user #{user_login} to #{team_login}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end

  desc("remove_user", "Remove a User from a Team")
  option(:netrc, type: :boolean)
  option(:client_id)
  option(:login)

  option(:org, required: true)
  option(:team, required: true)
  option(:user, required: true)

  def remove_user
    # build the client for the github api
    build_client(netrc: options[:netrc], client_id: options[:client_id], login: options[:login])

    # this is merely to ensure that the client is authenticated
    user
    say("Successfully authenticated as: #{user}", :green)

    org_login = options[:org]
    organization = find_organization_by!(login: org_login)
    say("Successfully resolved the Organization: #{organization.login}", :green)

    team_login = options[:team]
    team = find_team_by(organization:, login: team_login)
    say("Successfully resolved the Team: #{team.name}", :green)

    user_login = options[:user]
    user = find_user_by(login: user_login)

    team.remove_user(user:)

    say("Successfully removed the user #{user_login} from #{team_login}", :green)
  rescue octokit::unauthorized => authz_error
    say("error: #{authz_error}", :red)
  end
end
