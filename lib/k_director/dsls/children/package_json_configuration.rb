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
        # rubocop:disable Metrics/MethodLength
        def set_default_package_groups
          set_package_group('webpack'         , 'Webpack V5'                , %w[webpack webpack-cli webpack-dev-server])
          set_package_group('swc'             , 'SWC Transpiler'            , %w[@swc/cli @swc/core swc-loader])
          set_package_group('babel'           , 'Babel Transpiler'          , %w[@babel/core @babel/cli @babel/preset-env babel-loader])
          set_package_group('typescript'      , 'Typescript'                , %w[typescript ts-loader])
          set_package_group('semver-ruby'     , 'Semantic Release for Ruby' , %w[
                              semantic-release
                              @semantic-release/changelog
                              @semantic-release/git
                              @klueless-js/semantic-release-rubygem@github:klueless-js/semantic-release-rubygem
                            ])

          set_package_group('semver-nuxt'     , 'Semantic Release for Nuxt' , %w[
                              semantic-release
                              @semantic-release/changelog
                              @semantic-release/git
                            ])

          set_package_group('tailwind-nuxt'   , 'TailwindCSS for Nuxt'      , %w[
                              tailwindcss@latest
                              postcss@latest
                              autoprefixer@latest
                            ])

          set_package_group('svelte', 'Svelte' , %w[
                              @rollup/plugin-commonjs
                              @rollup/plugin-node-resolve
                              rollup
                              rollup-plugin-css-only
                              rollup-plugin-livereload
                              rollup-plugin-svelte
                              rollup-plugin-terser
                              svelte
                            ])

          # {
          #   "name": "svelte-app",
          #   "version": "1.0.0",
          #   "scripts": {
          #     "build": "rollup -c",
          #     "dev": "rollup -c -w",
          #     "start": "sirv public"
          #   },
          #   "devDependencies": {
          #     "@rollup/plugin-commonjs": "^16.0.0",
          #     "@rollup/plugin-node-resolve": "^10.0.0",
          #     "rollup": "^2.3.4",
          #     "rollup-plugin-css-only": "^3.0.0",
          #     "rollup-plugin-livereload": "^2.0.0",
          #     "rollup-plugin-svelte": "^7.0.0",
          #     "rollup-plugin-terser": "^7.0.0",
          #     "svelte": "^3.0.0"
          #   },
          #   "dependencies": {
          #     "sirv-cli": "^1.0.0"
          #   }
          # }

          set_package_group('storybook-nuxt' , 'Storybook for (Vite/Nuxt)' , %w[
                              @storybook/vue3@6.4.18
                              @storybook/addon-postcss@2.0.0
                              @storybook/addon-storysource@6.4.18
                              storybook-builder-vite
                            ])

          # Currently these two need to be forced
          # @storybook/addon-docs@6.4.18
          # @storybook/addon-essentials@6.4.18
        end
        # rubocop:enable Metrics/MethodLength

        def debug
          log.structure(package_groups, convert_data_to: :open_struct)
        end
      end
    end
  end
end

KConfig::Configuration.register(:package_json, KDirector::Dsls::Children::PackageJsonConfigurationExtension)
