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

        # Init an NPN package
        #
        # run npm init -y
        #
        # Note: npm init does not support --silent operation
        def npm_init
          run_command 'npm init -y'

          load

          self
        end

        # Space separated list of packages
        def npm_install(packages, options: nil)
          npm_add_or_install(packages, parse_options(options))

          self
        end
        alias npm_i npm_install

        def npm_add(packages, options: nil)
          npm_add_or_install(packages, parse_options(options, '--package-lock-only --no-package-lock'))

          self
        end
        alias npm_a npm_add

        def npm_add_group(key, options: nil)
          group = get_group(key)

          puts "Adding #{group.description}"

          npm_add(group.package_names, options: options)

          self
        end
        alias npm_ag npm_add_group

        # Add a group of NPN packages which get defined in configuration
        def npm_install_group(key, options: nil)
          group = get_group(key)

          puts "Installing #{group.description}"

          npm_install(group.package_names, options: options)

          self
        end

        # Load the existing package.json into memory
        #
        # ToDo: Would be useful to record the update timestamp on the package
        # so that we only load if the in memory package is not the latest.
        #
        # The reason this can happen, is because external tools such are
        # npm install are updating the package.json and after this happens
        # we need to call load, but if there is any bug in the code we may
        # for get to load, or we may load multiple times.
        def load
          raise KDirector::Error, 'package.json does not exist' unless File.exist?(package_file)

          # puts 'loading...'

          content = File.read(package_file)
          @package = JSON.parse(content)

          self
        end

        # Write the package.json file
        def write
          # puts 'writing...'

          content = JSON.pretty_generate(@package)

          File.write(package_file, content)

          self
        end

        # Remove a script reference by key
        def remove_script(key)
          remove(key, group: 'scripts')
          # load

          # @package['scripts']&.delete(key)

          # write

          self
        end

        # Add a script with key and value (command line to run)
        def add_script(key, value)
          set(key, value, group: 'scripts')

          self
        end

        # ----------------------------------------------------------------------
        # Attributes: Think getter/setter
        #
        # The following getter/setters can be referenced both inside and outside
        # of the fluent builder fluent API. They do not implement the fluent
        # interface unless prefixed by set_.
        #
        # set_: Only setters with the prefix _set are considered fluent.
        # ----------------------------------------------------------------------

        # Package
        # ----------------------------------------------------------------------

        # Load the package.json into a memory as object
        def package
          return @package if defined? @package

          load

          @package
        end

        # Package.settings is a hash of settings that can be applied to package.json
        # ----------------------------------------------------------------------

        # Settings
        #
        # Add multiple settings to the package.json
        # @param opts [Hash] Hash of settings to add
        #   opts[:group] is the group to add the settings to
        def settings(**opts)
          load

          group = opts.delete(:group)

          opts.each do |key, value|
            set_key_value(key, value, group: group)
          end

          write

          self
        end

        # Package.set
        # ----------------------------------------------------------------------

        # Set a property value in the package
        def set(key, value, group: nil)
          load

          set_key_value(key, value, group: group)

          write

          self
        end

        def remove(key, group: nil)
          load

          key = key.to_s.strip

          if group.nil?
            @package.delete(key)
          else
            group = group.to_s.strip
            @package[group]&.delete(key)
          end

          @package['scripts']&.delete(key)

          write

          self
        end

        # Package.sort using `npx sort-package-json`
        # ----------------------------------------------------------------------

        # Sort the package.json keys using `npx sort-package-json`
        def sort
          run_command 'npx sort-package-json'

          load

          self
        end

        # Dependency option
        # ----------------------------------------------------------------------

        # Getter for dependency option
        def dependency_option
          dependency_type == :development ? '-D' : '-P'
        end

        # Dependency type
        # ----------------------------------------------------------------------

        # Fluent setter for target folder
        # rubocop:disable Naming/AccessorMethodName
        def set_dependency_type(value)
          self.dependency_type = value

          self
        end
        # rubocop:enable Naming/AccessorMethodName

        # Package file
        # ----------------------------------------------------------------------

        # Fluent setter for package file
        # rubocop:disable Naming/AccessorMethodName
        def set_package_file(value)
          self.package_file = value

          self
        end
        # rubocop:enable Naming/AccessorMethodName

        # Setter for package file
        def package_file=(_value)
          @package_file = File.join(k_builder.target_folder, 'package.json')
        end

        # Remove package-lock.json
        # ----------------------------------------------------------------------

        def remove_package_lock
          file = File.join(k_builder.target_folder, 'package-lock.json')

          File.delete(file) if File.exist?(file)

          self
        end

        # Remove yarn.lock
        # ----------------------------------------------------------------------

        def remove_yarn_lock
          file = File.join(k_builder.target_folder, 'yarn.lock')

          File.delete(file) if File.exist?(file)

          self
        end

        # Create yarn.lock
        # ----------------------------------------------------------------------

        def create_yarn_lock
          run_command 'yarn install --check-files'

          self
        end

        # -----------------------------------
        # Helpers
        # -----------------------------------

        def parse_options(options = nil, required_options = nil)
          options = [] if options.nil?
          options = options.split if options.is_a?(String)
          options.reject(&:empty?)

          required_options = [] if required_options.nil?
          required_options = required_options.split if required_options.is_a?(String)

          options | required_options
        end

        def options_any?(options, *any_options)
          (options & any_options).any?
        end

        def execute(command)
          puts "RUN: #{command}"
          run_command command
          load
        end

        def npm_add_or_install(packages, options)
          # if -P or -D is not in the options then use the current builder dependency option
          options.push dependency_option unless options_any?(options, '-P', '-D')
          packages = packages.join(' ') if packages.is_a?(Array)
          command = "npm install #{options.join(' ')} #{packages}"
          execute command
        end

        # # Debug method to open the package file in vscode
        # # ToDo: Maybe remove
        # def vscode
        #   puts "cd #{output_path}"
        #   puts package_file
        #   run_command "code #{package_file}"
        # end

        private

        def get_group(key)
          group = configuration.package_json.package_groups[key]

          raise KConfig::PackageJson::Error, "unknown package group: #{key}" if group.nil?

          group
        end

        def set_key_value(key, value, group: nil)
          key = key.to_s.strip

          if group.nil?
            @package[key] = value
          else
            group = group.to_s.strip
            @package[group] = {} unless @package[group]
            @package[group][key] = value
          end
        end

        def run_command(command)
          parent.k_builder.run_command(command)
        end
      end
    end
  end
end
