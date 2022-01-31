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
            builder = KDirector::Builders::ActionsBuilder.new
          else
            builder.reset
          end

          new(k_builder, builder, **opts)
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
        builder.dom
      end

      # Used by child directors to inherit options from parent
      def inherited_opts(**opts)
        {
          on_exist: @options.on_exist,
          on_action: @options.on_action,
          template_base_folder: @options.template_base_folder
        }.merge(opts)
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

      def debug
        log.section_heading director_name

        h = options.to_h.sort.to_h
        h.each_key do |key|
          # requires k_funky
          log.kv(titleize.parse(key.to_s), h[key])
        end
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
