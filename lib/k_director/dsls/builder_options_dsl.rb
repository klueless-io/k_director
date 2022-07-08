# frozen_string_literal: true

module KDirector
  module Dsls
    # BuilderOptionsDsl is a DSL for generating builder options.
    class BuilderOptionsDsl < KDirector::Directors::BaseDirector
      def initialize(k_builder, builder, **opts)
        super(k_builder, builder, **opts)

        dom[:option_groups] = []
      end

      def default_template_base_folder
        'ruby/components/builder_options'
      end

      def add_group(name, params: [], flags: [], description: nil)
        group = {
          name: name,
          params: params,
          flags: flags,
          description: description
        }

        dom[:option_groups] << group

        self
      end
    end
  end
end
