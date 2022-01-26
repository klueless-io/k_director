# frozen_string_literal: true

module KDirector
  module Builders
    # Data builder for KBuilder Actions
    class ActionsBuilder < KDirector::Builders::DomBuilder
      def initialize
        super(schema)
      end

      def queue_action(action)
        dom[:actions] << current_node(action)
      end

      def actions
        dom[:actions]
      end

      private

      def schema
        {
          actions: []
        }
      end
    end
  end
end
