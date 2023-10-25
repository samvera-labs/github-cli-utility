# frozen_string_literal: true

require "thor"
require "io/console"

dir_path = File.dirname(__FILE__)
pattern = File.join(dir_path, "..", "lib", "**", "*rb")
paths = Dir.glob(pattern)
paths.each { |file| require(file) }

class Samvera::Gems < Thor
  attr_reader :client

  desc("auth", "Authenticate against the RubyGems API")
  option(:mfa, default: false, type: :boolean)
  option(:uri, required: false)
  option(:otp, required: false)
  def auth
    # Build the client for the RubyGems API
    build_client(api_key:, mfa: options[:mfa], uri: options[:uri], otp: options[:otp])
    client.gems

    # This is merely to ensure that the client is authenticated
    say("Successfully authenticated against the RubyGems API", :green)
  end

  desc("owners", "List the owners for a given Gem published to RubyGems")
  option(:mfa, default: false, type: :boolean)
  option(:uri)
  option(:otp)

  option(:name, required: true)
  def owners
    # Build the client for the RubyGems API
    build_client(api_key:, mfa: options[:mfa], uri: options[:uri], otp: options[:otp])

    gem_name = options[:name]
    owners = client.find_owners_by(gem_name:)

    say("The following users are owners for the Gem #{gem_name}:", :green)

    owners.each do |owner|
      say("#{owner.handle}", :yellow)
    end
  end

  desc("add_owner", "Add an owner for a given Gem")
  option(:mfa, default: false, type: :boolean)
  option(:uri)
  option(:otp)

  option(:name, required: true)
  option(:owner, required: true)
  def add_owner
    # Build the client for the RubyGems API
    build_client(api_key:, mfa: options[:mfa], uri: options[:uri], otp: options[:otp])

    gem_name = options[:name]
    found = client.find_gem_by(name: gem_name)

    say("Successfully resolved the Gem #{gem_name}", :green)

    owner_email = options[:owner]
    found.add_owner(email: owner_email)
    say("Successfully added the owner #{owner_email} to the Gem #{gem_name}", :green)
  end

  desc("remove_owner", "Remove an owner for a given Gem")
  option(:mfa, default: false, type: :boolean)
  option(:uri)
  option(:otp)

  option(:name, required: true)
  option(:owner, required: true)
  def remove_owner
    # Build the client for the RubyGems API
    build_client(api_key:, mfa: options[:mfa], uri: options[:uri], otp: options[:otp])

    gem_name = options[:name]
    found = client.find_gem_by(name: gem_name)

    say("Successfully resolved the Gem #{gem_name}", :green)

    owner_email = options[:owner]
    found.remove_owner(email: owner_email)
    say("Successfully removed the owner #{owner_email} from the Gem #{gem_name}", :green)
  end

  no_commands do

    def api_key
      @api_key ||= STDIN.getpass("Please enter your RubyGems API key:")
    end

    def build_client(**args)
      @client ||= Samvera::RubyGems::Client.new(**args)
    end
  end
end
