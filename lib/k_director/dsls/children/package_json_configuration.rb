# frozen_string_literal: true

# Attach configuration to the KBuilder module
module KDirector
  module Dsls
    module Children
      # PackageJson configuration extension for attachment to KConfig::Configuration
      module PackageJsonConfigurationExtension
        def package_json
          return @package_json if defined? @package_json

          @package_json = PackageJsonConfiguration.new
          @package_json.set_default_package_groups
          @package_json
        end

        def package_json_debug
          package_json.debug
        end
      end

      # PackageJson Configuration
      class PackageJsonConfiguration
        include KLog::Logging

        PackageGroup = Struct.new(:key, :description, :package_names)

        attr_accessor :package_groups

        def initialize
          @package_groups = {}
        end

        def set_package_group(key, description, package_names)
          package_groups[key] = PackageGroup.new(key, description, package_names)
        end

        # Setup the default package groups
        def set_default_package_groups
          set_package_group('webpack'         , 'Webpack V5'        , %w[webpack webpack-cli webpack-dev-server])
          set_package_group('swc'             , 'SWC Transpiler'    , %w[@swc/cli @swc/core swc-loader])
          set_package_group('babel'           , 'Babel Transpiler'  , %w[@babel/core @babel/cli @babel/preset-env babel-loader])
          set_package_group('typescript'      , 'Typescript'        , %w[typescript ts-loader])
          set_package_group('semantic-release', 'Semantic Release'  , %w[semantic-release github:klueless-js/semantic-release-rubygem @semantic-release/changelog @semantic-release/git])
        end

        def debug
          log.structure(package_groups, convert_data_to: :open_struct)
        end
      end
    end
  end
end

KConfig::Configuration.register(:package_json, KDirector::Dsls::Children::PackageJsonConfigurationExtension)
