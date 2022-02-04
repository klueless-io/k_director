# frozen_string_literal: true

module KDirector
  module Dsls
    module Children
      # PackageJson DSL provides package.json manipulation actions such as.
      class PackageJson < KDirector::Directors::ChildDirector
        # In memory representation of the package.json file that is being created

        attr_writer :package

        attr_reader :package_file
        attr_accessor :dependency_type

        def initialize(parent, **opts)
          super(parent, **opts)

          set_package_file('package.json')
          set_dependency_type(:development)

          # defaults = {
          #   repo_name: opts[:repo_name], # || parent.builder.dom&[:PackageJson]&[:repo_name]
          #   username: opts[:username] || default_PackageJson_username, # || parent.builder.dom&[:PackageJson]&[:username]
          #   organization: opts[:organization] # || parent.builder.dom&[:PackageJson]&[:organization]
          # }

          # parent.builder.group_set(:PackageJson, **repo_info_hash(**defaults))
        end

        # ----------------------------------------------------------------------
        # Fluent interface
        # ----------------------------------------------------------------------

        # Change context to production, new dependencies will be for production
        def production
          set_dependency_type(:production)

          self
        end

        # Change context to development, new dependencies will be for development
        def development
          set_dependency_type(:development)

          self
        end
      end
    end
  end
end
