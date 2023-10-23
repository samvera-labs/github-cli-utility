# frozen_string_literal: true




module Samvera
  module GraphQL
    class Types::QueryType < ::GraphQL::Schema::Object
      field :projects, [ProjectType], "Returns all projects"
    end
  end
end
