# frozen_string_literal: true

# klueless-io
# k_director
# kluless-sites

module KDirector
  module Dsls
    module Children
      # Github DSL provides useful GitHub actions such as (create, delete, list, open repository).
      class Github < KDirector::Directors::ChildDirector
        def initialize(parent, **opts)
          super(parent, **opts)

          @options.repo_name          ||= parent.options.repo_name
          @options.repo_organization  ||= parent.options.repo_organization
        end

        def repo
          return parent.options.repo if defined? parent.options.repo

          parent.options.repo = OpenStruct.new(name: nil, organization: nil)
        end

        def name
          repo.repo_name
        end

        def organization
          repo.repo_organization
        end
      end
    end
  end
end
