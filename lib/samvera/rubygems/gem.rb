# frozen_string_literal: true

require_relative "resource"

module Samvera
  module RubyGems
    class Gem < Resource
      attr_accessor :authors,
                    :bug_tracker_uri,
                    :changelog_uri,
                    :dependencies,
                    :documentation_uri,
                    :downloads,
                    :funding_uri,
                    :gem_uri,
                    :homepage_uri,
                    :info,
                    :licenses,
                    :mailing_list_uri,
                    :metadata,
                    :name,
                    :platform,
                    :project_uri,
                    :sha,
                    :source_code_uri,
                    :version,
                    :version_created_at,
                    :version_downloads,
                    :wiki_uri,
                    :yanked

      def add_owner(email:)
        path = "gems/#{name}/owners"
        @client.execute_post_request(path:, email:)
        self
      end

      def remove_owner(email:)
        path = "gems/#{name}/owners"
        @client.execute_delete_request(path:, email:)
        self
      end
    end
  end
end
