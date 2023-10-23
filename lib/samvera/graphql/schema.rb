# frozen_string_literal: true


module Samvera
  module GraphQL
    class Schema < ::GraphQL::Schema
      query Types::Query
      mutation Types::Mutation
      use GraphQL::Batch

      def self.resolve_type(type, object, ctx)
        type_class_name = "::Types::#{object.class}Type"
        type_class = type_class_name.safe_constantize
        raise ArgumentError, "Cannot resolve type for class #{type_class_name}" unless type_class.present?

        type_class
      end

      def self.object_from_id(node_id, ctx)
        return unless node_id.present?

        record_class_name, record_id = GraphQL::Schema::UniqueWithinType.decode(node_id)
        record_class = record_class_name.safe_constantize
        return unless record_class.present?

        record_class.find_by(id: record_id)
      end

      def self.id_from_object(object, type, ctx)
        GraphQL::Schema::UniqueWithinType.encode(object.class.name, object.id)
      end
    end
  end
end
