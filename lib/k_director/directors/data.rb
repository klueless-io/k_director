# frozen_string_literal: true

module KDirector
  module Dsls
    module Children
      # Blueprint DSL is used to add files to the target folder.
      #
      # A blueprint is a recipe that you can follow to build out assets on the target application
      class Blueprint < KDirector::Directors::ChildDirector
        # Add a single file into the code base
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

        # def template_content(template_file, **opts)
        #   template_parts = [template_base_folder, opts[:template_subfolder], template_file].reject(&:blank?)
        #   template_file = File.join(*template_parts)

        #   file = k_builder.find_template_file(template_file)
        #   File.read(file)
        # end

        def run_template_script(template_file, **opts)
          template_parts = [template_base_folder, opts[:template_subfolder], template_file].reject(&:blank?)
          template_path = File.join(*template_parts)

          script = k_builder.process_any_content(template_file: template_path, **opts)

          run_script(script)
        end
      end
    end
  end
end
