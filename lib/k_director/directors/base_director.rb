# frozen_string_literal: true

module KDirector
  module Directors
    # Base Director is paired with the ActionsBuilder and provides a base
    # on which to build code generation directors.
    class BaseDirector
      include KLog::Logging

      class << self
        def init(k_builder, builder = nil, **opts)
          if builder.nil?
            builder = builder_type.new
          else
            builder.reset
          end

          new(k_builder, builder, **opts)
        end

        def default_builder_type(type)
          @builder_type = type
        end

        def builder_type
          return @builder_type if defined? @builder_type

          @builder_type = KDirector::Builders::ActionsBuilder
        end
      end

      attr_reader :builder
      attr_reader :k_builder
      attr_reader :options

      def initialize(k_builder, builder, **opts)
        @k_builder  = k_builder
        @builder    = builder
        @options    = OpenStruct.new(**opts)

        @options.director_name        ||= default_director_name
        @options.template_base_folder ||= default_template_base_folder
        @options.on_exist             ||= :skip       # %i[skip write compare]
        @options.on_action            ||= :queue      # %i[queue execute]
        @options.active = true unless defined?(@options.active)
      end

      def data(name = nil, **opts)
        KDirector::Directors::Data.new(self, name, **opts)

        self
      end

      def settings(**opts)
        KDirector::Directors::Data.new(self, :settings, **opts)

        self
      end

      def dom
        return builder.dom if defined?(builder.dom)

        nil
      end

      def typed_dom
        builder.build
      end

      # Used by child directors to inherit options from parent
      def inherited_opts(**opts)
        {
          on_exist: @options.on_exist,
          on_action: @options.on_action,
          template_base_folder: @options.template_base_folder,
          active: @options.active
        }.merge(opts)
      end

      def configuration
        k_builder.configuration
      end

      def active?
        @options.active == true
      end

      def director_name
        @options.director_name
      end

      def director_name=(name)
        @options.director_name = name
      end

      def template_base_folder
        @options.template_base_folder
      end

      def on_exist
        @options.on_exist
      end

      def on_action
        @options.on_action
      end

      # Add a single file into the code base
      #
      # This is a wrapper around add_file that will add the file to the codebase using template path rules
      #
      # @param [String] output_filename The output file name, this can be a relative path
      # @param [Hash] **opts The options
      # @option opts [String] :template_filename Template filename can be set or it will default to the same value as the output file name
      # @option opts [String] :template_subfolder Template subfolder
      def add(output_file, **opts)
        template_file = opts[:template_file] || output_file
        template_parts = [template_base_folder, opts[:template_subfolder], template_file].reject(&:blank?)
        template_path = File.join(*template_parts)

        # maybe template_file should be renamed to template_path in k_builder
        opts[:template_file] = template_path

        add_file(output_file, **opts)
      end

      def oadd(name, **opts)
        add(name, **{ open: true          }.merge(opts))
      end

      def tadd(name, **opts)
        add(name, **{ open_template: true }.merge(opts))
      end

      def fadd(name, **opts)
        add(name, **{ on_exist: :write    }.merge(opts))
      end

      # Add a file to target folder
      def add_file(file, **opts)
        opts = {
          on_exist: on_exist
        }.merge(opts)

        opts[:dom] = dom.except(:actions) if dom

        handle_action(k_builder.add_file_action(file, **opts))

        self
      end

      # Set current target folder
      # rubocop:disable Naming/AccessorMethodName
      def set_current_folder_action(folder_key)
        # RUN (not handle), current folder effects subsequent actions and so it needs to be executed straight away.
        run_action(k_builder.set_current_folder_action(folder_key))

        self
      end
      # rubocop:enable Naming/AccessorMethodName
      alias cd set_current_folder_action

      # Add content to the clipboard
      #
      # @option opts [String] :content Supply the content that you want to write to the file
      # @option opts [String] :template Supply the template that you want to write to the file, template will be processed  ('nobody') From address
      # @option opts [String] :content_file File with content, file location is based on where the program is running
      # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
      #
      # Extra options will be used as data for templates, e.g
      # @option opts [String] :to Recipient email
      # @option opts [String] :body The email's body
      def add_clipboard(**opts)
        # RUN (not handle), current folder effects subsequent actions and so it needs to be executed straight away.
        run_action(k_builder.add_clipboard_action(**opts))

        self
      end
      alias clipboard_copy add_clipboard

      # Run a command using shell, this is useful with command line tools
      def run_command(command)
        handle_action(k_builder.run_command_action(command))

        self
      end

      # Run a command using Open3.capture2, can be used in place of run_command
      # but is also useful with multiline scripts
      def run_script(script)
        handle_action(k_builder.run_script_action(script))

        self
      end

      # play any un-played actions
      def play_actions
        k_builder.play_actions(builder.actions)
      end

      # Common child directors

      def github(**opts, &block)
        github = KDirector::Dsls::Children::Github.new(self, **opts)
        github.instance_eval(&block) if github.active? && block_given?

        self
      end

      def package_json(**opts, &block)
        package_json = KDirector::Dsls::Children::PackageJson.new(self, **opts)
        package_json.instance_eval(&block) if package_json.active? && block_given?

        self
      end

      def blueprint(**opts, &block)
        blueprint = KDirector::Dsls::Children::Blueprint.new(self, **opts)
        blueprint.instance_eval(&block) if blueprint.active? && block_given?

        self
      end

      def debug
        debug_options
        debug_dom
      end

      def debug_options
        log.section_heading director_name

        h = options.to_h.sort.to_h
        h.each_key do |key|
          # requires k_funky
          log.kv(titleize.parse(key.to_s), h[key])
        end

        nil
      end

      def debug_dom
        log.section_heading 'DOM'

        builder.debug

        nil
      end

      # def debug_info
      #   log.kv 'Template Root Folder'   , k_builder.template_folders.folder_paths
      #   log.kv 'Template Base Folder'   , template_base_folder
      #   log.kv 'on_exist'               , on_exist
      #   log.kv 'on_action'              , on_action
      # end

      private

      def default_template_base_folder
        ''
      end

      def default_director_name
        titleize.parse(self.class.name.split('::').last)
      end

      def folder_parts(*parts)
        parts.reject(&:blank?).map(&:to_s)
      end

      def handle_action(action)
        builder.queue_action(action)
        k_builder.play_action(action) if on_action == :execute
      end

      # run action will queue an action just like handle_action, but it will also run it immediately
      def run_action(action)
        builder.queue_action(action)
        k_builder.run_action(action)
      end

      def titleize
        require 'handlebars/helpers/string_formatting/titleize'
        Handlebars::Helpers::StringFormatting::Titleize.new
      end
    end
  end
end
