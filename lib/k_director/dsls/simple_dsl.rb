# frozen_string_literal: true

module KDirector
  module Dsls
    # BasicDsl is a DSL for generating basic projects.
    class BasicDsl < KDirector::Directors::BaseDirector
      def default_template_base_folder
        'basic'
      end
    end
  end
end
