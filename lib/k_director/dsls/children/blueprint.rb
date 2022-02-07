# frozen_string_literal: true

module KDirector
  module Dsls
    module Children
      # Blueprint DSL is used to add files to the target folder.
      #
      # A blueprint is a recipe that you can follow to build out assets on the target application
      class Blueprint < KDirector::Directors::ChildDirector
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
