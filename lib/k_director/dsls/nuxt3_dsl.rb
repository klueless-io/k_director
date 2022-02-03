# frozen_string_literal: true

module KDirector
  module Dsls
    # Nuxt3Dsl is a DSL for generating Nuxt3.x projects.
    class Nuxt3Dsl < KDirector::Directors::BaseDirector
      def default_template_base_folder
        'nuxt3'
      end

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

      # def blueprint(**opts, &block)
      #   blueprint = Dsl::Blueprint.new(self, **opts)
      #   blueprint.instance_eval(&block)

      #   self
      # end

      # def app(**opts, &block)
      #   app = Dsl::Nuxt3App.new(self, **opts)
      #   app.instance_eval(&block)

      #   self
      # end

      # def layouts(**opts, &block)
      #   layouts = Dsl::Nuxt3Layout.new(self, **opts)
      #   layouts.instance_eval(&block)

      #   self
      # end

      # def pages(**opts, &block)
      #   pages = Dsl::Nuxt3Page.new(self, **opts)
      #   pages.instance_eval(&block)

      #   self
      # end

      # def components(**opts, &block)
      #   components = Dsl::Nuxt3Component.new(self, **opts)
      #   components.instance_eval(&block)

      #   self
      # end

      # def stories(**opts, &block)
      #   stories = Dsl::Nuxt3Story.new(self, **opts)
      #   stories.instance_eval(&block)

      #   self
      # end

      # def apis(**opts, &block)
      #   apis = Dsl::Nuxt3Api.new(self, **opts)
      #   apis.instance_eval(&block)

      #   self
      # end
    end

    #   class Nuxt3App < KDirector::Directors::ChildDirector

    #     def setup_tailwind
    #       run_command('yarn add -D tailwindcss@latest')
    #       run_command('yarn add -D postcss@^8.3.11') # @latest
    #       run_command('yarn add -D autoprefixer@latest')
    #       run_command('npx tailwindcss init -p')
    #     end

    #     def setup_storybook
    #       run_command('yarn add -D @storybook/vue3')
    #       run_command('yarn add -D @storybook/addon-docs')
    #       run_command('yarn add -D @storybook/addon-essentials')
    #       run_command('yarn add -D @storybook/addon-storysource')
    #       run_command('yarn add -D @storybook/addon-postcss')
    #       run_command('yarn add -D storybook-builder-vite')
    #     end
    # # >> "postcss": "^8.4.5", // Post CSS 8.4.5 does not work with storybook
    #   end

    #   class Nuxt3Layout < KDirector::Directors::ChildDirector
    #     # @param [Hash] **opts The options
    #     # @option opts [String] :variant Template variant name
    #     # @option opts [String] :template_subfolder Template subfolder
    #     def layout(name, **opts)
    #       variant = opts[:variant] || name
    #       template_filename = "#{dasherize.parse(variant.to_s)}.vue"
    #       template_file = resolve_template_file("nuxt3/layouts", template_filename, **opts)
    #       output_filename = "#{dasherize.parse(name.to_s)}.vue"
    #       output_file = File.join('layouts', output_filename)

    #       opts = {
    #         template_file: template_file
    #       }.merge(opts)

    #       add_file(output_file, **opts)
    #     end

    #     def olayout(name, **opts); layout(name, **{ open: true          }.merge(opts)); end
    #     def tlayout(name, **opts); layout(name, **{ open_template: true }.merge(opts)); end
    #     def flayout(name, **opts); layout(name, **{ on_exist: :write    }.merge(opts)); end

    #     def sample_layout(name, **opts)
    #       layout(name, template_subfolder: 'samples', **opts)
    #     end

    #     def osample_layout(name, **opts); sample_layout(name, **{ open: true          }.merge(opts)); end
    #     def tsample_layout(name, **opts); sample_layout(name, **{ open_template: true }.merge(opts)); end
    #     def fsample_layout(name, **opts); sample_layout(name, **{ on_exist: :write    }.merge(opts)); end

    #   end

    #   class Nuxt3Page < KDirector::Directors::ChildDirector
    #     # @param [Hash] **opts The options
    #     # @option opts [String] :subfolder Output subfolder
    #     # @option opts [String] :variant Template variant name
    #     # @option opts [String] :template_subfolder Template subfolder
    #     def page(name, **opts)
    #       variant = opts[:variant] || name
    #       template_filename = "#{dasherize.parse(variant.to_s)}.vue"
    #       template_file = resolve_template_file("nuxt3/pages", template_filename, **opts)
    #       output_filename = "#{dasherize.parse(name.to_s)}.vue"
    #       parts = ['pages', opts[:subfolder], output_filename].reject(&:blank?).map(&:to_s)
    #       output_file = File.join(*parts)

    #       opts = {
    #         template_file: template_file,
    #         dom: {
    #           page_name: opts[:page_name] || name,
    #           main_key: opts[:main_key] || :sample
    #         }
    #       }.merge(opts)

    #       add_file(output_file, **opts)
    #     end
    #     def opage(name, **opts); page(name, **{ open: true          }.merge(opts)); end
    #     def tpage(name, **opts); page(name, **{ open_template: true }.merge(opts)); end
    #     def fpage(name, **opts); page(name, **{ on_exist: :write    }.merge(opts)); end

    #     def sample_page(name, **opts)
    #       page(name, template_subfolder: 'samples', **opts)
    #     end

    #     def osample_page(name, **opts); sample_page(name, **{ open: true          }.merge(opts)); end
    #     def tsample_page(name, **opts); sample_page(name, **{ open_template: true }.merge(opts)); end
    #     def fsample_page(name, **opts); sample_page(name, **{ on_exist: :write    }.merge(opts)); end

    #     def tw_page(name, element, element_name, **opts)
    #       options = {
    #         subfolder: "tailwind/#{element}",
    #         variant: 'one-component',
    #         dom: {
    #           page_name: "#{opts[:page_name] || name}",
    #           vue_component: "<#{camel.parse(element.to_s)}#{camel.parse(element_name.to_s)} />"
    #         }
    #       }.merge(opts)

    #       page(name, **options)
    #     end
    #   end

    #   class Nuxt3Component < KDirector::Directors::ChildDirector
    #     # @param [Hash] **opts The options
    #     # @option opts [String] :variant Template variant name
    #     # @option opts [String] :template_subfolder Template subfolder
    #     def component(name, **opts)
    #       variant = opts[:variant] || name
    #       template_filename = "#{camel.parse(variant.to_s)}.vue"
    #       template_file = resolve_template_file("nuxt3/components", template_filename, **opts)
    #       output_filename = "#{camel.parse(name.to_s)}.vue"
    #       parts = ['components', opts[:subfolder], output_filename].reject(&:blank?).map(&:to_s)
    #       output_file = File.join(*parts)

    #       opts = {
    #         template_file: template_file,
    #         dom: {
    #           component_name: opts[:component_name] || name
    #         }
    #       }.merge(opts)

    #       add_file(output_file, **opts)
    #     end
    #     def ocomponent(name, **opts); component(name, **{ open: true          }.merge(opts)); end
    #     def tcomponent(name, **opts); component(name, **{ open_template: true }.merge(opts)); end
    #     def fcomponent(name, **opts); component(name, **{ on_exist: :write    }.merge(opts)); end

    #     def sample_component(name, **opts)
    #       component(name, template_subfolder: 'samples', **opts)
    #     end

    #     def osample_component(name, **opts); sample_component(name, **{ open: true          }.merge(opts)); end
    #     def tsample_component(name, **opts); sample_component(name, **{ open_template: true }.merge(opts)); end
    #     def fsample_component(name, **opts); sample_component(name, **{ on_exist: :write    }.merge(opts)); end

    #     def tw_component(name, element, element_name, **opts)
    #       tw_element_file =  k_builder.target_file(element.to_s, "#{element_name}.html", folder_key: :tailwind_elements)
    #       tw_element = File.exist?(tw_element_file) ? File.read(tw_element_file) : "element not found: #{tw_element_file}"

    #       options = {
    #         subfolder: element,
    #         variant: :tw_html_component,
    #         dom: {
    #           component_name: "#{opts[:component_name] || name}",
    #           tailwind_element: tw_element
    #         }
    #       }.merge(opts)

    #       component(name, **options)
    #     end
    #   end

    #   class Nuxt3Story < KDirector::Directors::ChildDirector
    #     # @param [Hash] **opts The options
    #     # @option opts [String] :variant Template variant name
    #     # @option opts [String] :template_subfolder Template subfolder
    #     def component_story(name, **opts)
    #       variant = opts[:variant] || name
    #       template_filename = "#{variant.to_s}.stories.js"
    #       template_file = resolve_template_file("nuxt3/stories", template_filename, **opts)
    #       output_filename = "#{camel.parse(name.to_s)}.stories.js"
    #       output_file = File.join('stories', output_filename)

    #       opts = {
    #         template_file: template_file,
    #       }.merge(opts)

    #       add_file(output_file, **opts)
    #     end

    #     def ocomponent_story(name, **opts); component_story(name, **{ open: true          }.merge(opts)); end
    #     def tcomponent_story(name, **opts); component_story(name, **{ open_template: true }.merge(opts)); end
    #     def fcomponent_story(name, **opts); component_story(name, **{ on_exist: :write    }.merge(opts)); end

    #     def sample_component_story(name, **opts)
    #       component_story(name, template_subfolder: 'samples', **opts)
    #     end

    #     def osample_component_story(name, **opts); component_story(name, **{ open: true          }.merge(opts)); end
    #     def tsample_component_story(name, **opts); component_story(name, **{ open_template: true }.merge(opts)); end
    #     def fsample_component_story(name, **opts); component_story(name, **{ on_exist: :write    }.merge(opts)); end
    #   end

    #   class Nuxt3Api < KDirector::Directors::ChildDirector
    #     # @param [Hash] **opts The options
    #     # @option opts [String] :variant Template variant name
    #     # @option opts [String] :template_subfolder Template subfolder
    #     def api(name, **opts)
    #       variant = opts[:variant] || name
    #       template_filename = "#{dasherize.parse(variant.to_s)}.ts"
    #       template_file = resolve_template_file("nuxt3/server/api", template_filename, **opts)
    #       output_filename = "#{dasherize.parse(name.to_s)}.ts"
    #       output_file = File.join('server/api', output_filename)

    #       opts = {
    #         template_file: template_file,
    #       }.merge(opts)

    #       add_file(output_file, **opts)
    #     end

    #     def oapi(name, **opts); api(name, **{ open: true          }.merge(opts)); end
    #     def tapi(name, **opts); api(name, **{ open_template: true }.merge(opts)); end
    #     def fapi(name, **opts); api(name, **{ on_exist: :write    }.merge(opts)); end

    #     def sample_api(name, **opts)
    #       api(name, template_subfolder: 'samples', **opts)
    #     end

    #     def osample_api(name, **opts); sample_api(name, **{ open: true          }.merge(opts)); end
    #     def tsample_api(name, **opts); sample_api(name, **{ open_template: true }.merge(opts)); end
    #     def fsample_api(name, **opts); sample_api(name, **{ on_exist: :write    }.merge(opts)); end
    #   end
  end
end
