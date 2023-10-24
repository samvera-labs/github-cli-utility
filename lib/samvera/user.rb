# frozen_string_literal: true

require_relative "repository"

module Samvera
  class User < Owner
    attr_accessor :bio,
                  :blog,
                  :collaborators,
                  :company,
                  :created_at,
                  :disk_usage,
                  :email,
                  :events_url,
                  :followers,
                  :followers_url,
                  :following,
                  :following_url,
                  :gists_url,
                  :gravatar_id,
                  :hireable,
                  :html_url,
                  :location,
                  :name,
                  :organizations_url,
                  :owned_private_repos,
                  :plan,
                  :private_gists,
                  :public_gists,
                  :public_repos,
                  :received_events_url,
                  :repos_url,
                  :site_admin,
                  :starred_url,
                  :subscriptions_url,
                  :total_private_repos,
                  :twitter_username,
                  :two_factor_authentication,
                  :type,
                  :updated_at

    # @param client [Octokit::Client]
    # @param response [Sawyer::Resource]
    def self.build_from_response(client:, response:)
      attrs = response.to_hash
      attrs.delete(:plan)

      new(client:, **attrs)
    end

    def self.find_by(client:, login:, **options)
      response = client.user(login, **options)
      build_from_response(client:, response:)
    rescue Octokit::NotFound
      nil
    end
  end
end
