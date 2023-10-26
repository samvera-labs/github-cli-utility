# frozen_string_literal: true

require_relative "resource"

module Samvera
  module RubyGems
    class User < Resource
      attr_accessor :email,
                    :handle,
                    :id

    end
  end
end
