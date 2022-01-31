# frozen_string_literal: true

module KDirector
  module Directors
    # Data can update the underlying ActionBuilder DOM.
    class Data
      attr_reader :parent
      attr_reader :name

      def initialize(parent, name, **opts)
        @parent = parent
        @name   = name

        parent.builder.group_set(name, **opts)
      end
    end
  end
end
