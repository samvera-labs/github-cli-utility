# frozen_string_literal: true


module Samvera
  module GraphQL
    class Types::MutationType < GraphQL::Schema::Object
      field :create_project, mutation: Mutations::AddProject
    end
  end
end
