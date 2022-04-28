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

      def add_group(name, params: [], flags: [])
        group = {
          name: name,
          params: params,
          flags: flags
        }

        dom[:option_groups] << group

        self
      end

      # def build_options_builder(file)
      #   .add_file('builder_options.rb',
      #             template_file: 'ruby/components/builder_options/builder_options.rb',
      #             dom: director.dom,
      #             on_exist: :write)

      # end
    end
  end
end
