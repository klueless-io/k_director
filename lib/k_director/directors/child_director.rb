# frozen_string_literal: true

module KDirector
  module Directors
    # Child directors hang of a parent director and provide fluent builders for
    # specialized flow control, e.g branching of a RubyGem Director into a GitHub
    # Child director
    class ChildDirector < KDirector::Directors::BaseDirector
      attr_reader :parent

      def initialize(parent, **opts)
        @parent = parent

        super(parent.k_builder, parent.builder, **@parent.inherited_opts(**opts))
      end
    end
  end
end
