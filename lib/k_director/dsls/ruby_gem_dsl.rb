# frozen_string_literal: true

module KDirector
  module Dsls
    # RubyGemDsl is a DSL for generating RubyGem projects.
    class RubyGemDsl < KDirector::Directors::BaseDirector
      def default_template_base_folder
        'ruby/gem'
      end

      def github(**opts, &block)
        github = KDirector::Dsls::Children::Github.new(self, **opts)
        github.instance_eval(&block) if block_given?

        self
      end

      def blueprint(**opts, &block)
        blueprint = KDirector::Dsls::Children::Blueprint.new(self, **opts)
        blueprint.instance_eval(&block) if block_given?

        self
      end
    end
  end
end
