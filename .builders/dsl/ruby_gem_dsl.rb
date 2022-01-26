# frozen_string_literal: true

module Dsl
  class RubyGemDsl < Dsl::Directors::BaseDirector
    def default_director_name
      'Ruby Gem'
    end

    def repo_name
      options.repo_name
    end

    def repo_account
      options.repo_account
    end

    # def default_template_base_folder
    # end
    # def initialize(k_builder, builder, **opts)
    #   super(k_builder, builder, **opts)
    #   # @on_action  = opts[:on_action] || :queue      # %i[queue execute]
    # end
    def github(**opts, &block)
      github = Dsl::Github.new(self, **opts)
      github.instance_eval(&block) 

      self
    end

    def blueprint(**opts, &block)
      blueprint = Dsl::RubyGemBlueprint.new(self, **opts)
      blueprint.instance_eval(&block) 

      self
    end
  end

  class RubyGemBlueprint < Dsl::Directors::ChildDirector
    def template_content(template_filename)
      template_parts = [template_base_folder, template_filename]
      template_file = File.join(*template_parts)

      file = k_builder.find_template_file(template_file)
      File.read(file)
    end

    def run_template_script(template_filename, **opts)
      template_parts = [template_base_folder, template_filename]
      template_file = File.join(*template_parts)
      
      script = k_builder.process_any_content(template_file: template_file, **opts)

      run_script(script)
      # action = k_builder.run_script_action(script)
      # run_action(action)
    end

    # Create a single file
    #
    # @param [String] output_filename The output file name, this can be a relative path
    # @param [Hash] **opts The options
    # @option opts [String] :template_filename Template filename can be set or it will default to the same value as the output file name
    # @option opts [String] :template_subfolder Template subfolder
    def add(output_file, **opts)
      template_file = opts[:template_file] || output_file
      template_parts = [template_base_folder, opts[:template_subfolder], opts[:template_variant], template_file].reject(&:blank?)

      opts[:template_file] = File.join(*template_parts)

      add_file(output_file, **opts)
    end

    def oadd(name, **opts); add(name, **{ open: true          }.merge(opts)); end
    def tadd(name, **opts); add(name, **{ open_template: true }.merge(opts)); end
    def fadd(name, **opts); add(name, **{ on_exist: :write    }.merge(opts)); end
  end
end
