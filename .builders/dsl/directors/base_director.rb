# frozen_string_literal: true

module Dsl
  module Directors
    class BaseDirector
      include KLog::Logging

      class << self
        def init(k_builder, builder = nil, **opts)
          if builder.nil?
            builder = Dsl::Builders::ActionsBuilder.new
          else
            builder.reset
          end

          new(k_builder, builder, **opts)
        end
      end

      attr_reader :builder
      attr_reader :k_builder
      attr_reader :options
      attr_accessor :dom
    
      def initialize(k_builder, builder, **opts)
        @k_builder  = k_builder
        @builder    = builder
        @options    = OpenStruct.new(**opts)

        @options.director_name        ||= default_director_name
        @options.template_base_folder ||= default_template_base_folder
        @options.on_exist             ||= :skip       # %i[skip write compare]
        @options.on_action            ||= :queue      # %i[queue execute]
      end

      def director_name
        @options.director_name
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

      def add_file(file, **opts)
        opts = {
          on_exist: on_exist
        }.merge(opts)

        opts[:dom] = dom if dom

        handle_action(k_builder.add_file_action(file, **opts))

        self
      end

      def set_current_folder_action(folder_key)
        # RUN (not handle)
        run_action(k_builder.set_current_folder_action(folder_key))

        self
      end
      alias cd set_current_folder_action

      def run_command(command)
        handle_action(k_builder.run_command_action(command))

        self
      end

      def run_script(script)
        handle_action(k_builder.run_script_action(script))

        self
      end

      def play_actions
        k_builder.play_actions(builder.actions)
      end

      def debug
        log.section_heading director_name

        h = options.to_h.sort.to_h
        h.keys.each do |key|
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
        titleize.parse(self.class.name.split("::").last)
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
    end
  end
end