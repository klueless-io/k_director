# frozen_string_literal: true

module KDirector
  module Builders
    # Data builder for KBuilder Actions
    class ActionsBuilder < KDirector::Builders::DomBuilder
      def initialize_dom
        set(:actions, [])
      end

      def queue_action(action)
        add(:actions, action)
      end

      def actions
        dom[:actions]
      end
    end
  end
end
