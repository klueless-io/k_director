# frozen_string_literal: true

module Dsl
  module Builders
    class DomBuilder
      attr_reader :dom
      attr_reader :node

      def initialize(dom = nil)
        @dom = dom || schema
      end

      def current_node(node)
        @node = node
      end

      alias last_node node

      def reset
        @dom = schema
        @last_node = nil
      end

      def schema
        {}
      end

      def logit
        puts JSON.pretty_generate(dom)
        # log.structure(dom)

        self
      end

      def data
        KUtil.data.to_open_struct(@dom)
      end
    end
  end
end
