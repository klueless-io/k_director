# frozen_string_literal: true

module Dsl
  module Directors
    class ChildDirector < Dsl::Directors::BaseDirector
      attr_reader :parent

      def initialize(parent, **opts)
        @parent = parent

        opts = {
          on_exist: parent.on_exist,
          on_action: parent.on_action,
          template_base_folder: parent.template_base_folder
        }.merge(opts)

        super(parent.k_builder, parent.builder, **opts)
      end

      def debug
        parent.debug

        super
      end
    end
  end
end
