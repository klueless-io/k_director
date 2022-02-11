# frozen_string_literal: true

module KDirector
  module Builders
    # Actions document builder
    class ActionsBuilder < KDirector::Builders::DomBuilder
      attr_reader :actions
      attr_reader :last_action

      def reset
        super
        @actions = []
        @last_action = {}
      end

      def queue_action(action)
        @actions << action
        @last_action = action
      end

      def debug
        puts JSON.pretty_generate(actions)
        super

        self
      end
    end
  end
end
