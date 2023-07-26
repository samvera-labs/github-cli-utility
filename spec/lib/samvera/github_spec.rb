# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Github do
  subject(:cli) { described_class.new }

  describe "#client_with_access_token" do
    let(:client) { cli.client_with_access_token }

    before do
      allow(STDIN).to receive(:getpass).and_return("test access token")
    end

    it "constructs the GitHub API client using an API access token" do
      expect(client).to be_a(Octokit::Client)
    end
  end

  describe "#client_with_secret" do
    let(:client) { cli.client_with_secret }

    before do
      allow(STDIN).to receive(:getpass).and_return("test secret")
    end

    it "constructs the GitHub API client using an API access token" do
      expect(client).to be_a(Octokit::Client)
    end
  end

  describe "#client_with_password" do
    let(:client) { cli.client_with_password }

    before do
      allow(STDIN).to receive(:getpass).and_return("test password")
    end

    it "constructs the GitHub API client using an API access token" do
      expect(client).to be_a(Octokit::Client)
    end
  end


  describe "#client_with_netrc" do
    let(:client) { cli.client_with_netrc }

    it "constructs the GitHub API client using the .netrc credentials" do
      expect(client).to be_a(Octokit::Client)
    end
  end

end
