# frozen_string_literal: true

module KDirector
  module Dsls
    # RubyGemDsl is a DSL for generating RubyGem projects.
    class RubyGemDsl < KDirector::Directors::BaseDirector
      def default_template_base_folder
        'ruby/gem'
      end
    end
  end
end
