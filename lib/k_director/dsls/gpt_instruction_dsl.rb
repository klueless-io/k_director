# frozen_string_literal: true

module KDirector
  module Dsls
    class PanelOpts
      attr_accessor :name, :title, :arrow_left, :arrow_top, :panel_height

      def initialize(name, title: nil, arrow_left: 50, arrow_top: 50, panel_height: 120)
        @name = name
        @title = title || titleize(name)
        @arrow_left = arrow_left
        @arrow_top = arrow_top
        @panel_height = panel_height
      end

      def debug
        puts format('%-30s %s', 'Panel Config:', @name)
        puts format('%-30s %s', 'Title:', @title)
        puts format('%-30s %s', 'Arrow Left:', @arrow_left)
        puts format('%-30s %s', 'Arrow Top:', @arrow_top)
        puts format('%-30s %s', 'Panel Height:', @panel_height)
      end

      def clean_opts(**opts)
        opts.merge(name: @name, title: @title, arrow_left: @arrow_left, arrow_top: @arrow_top, panel_height: @panel_height)
      end

      def titleize(value)
        Cmdlet::Case::Title.new.call(value.to_s)
      end
    end

    class PanelConfiguration
      attr_accessor :role, :overview, :commands, :guidelines, :response
    
      DEFAULT_OPTIONS = {
        role: { title: 'AI Role', arrow_left: 50, arrow_top: 50 },
        overview: { arrow_left: 950, arrow_top: 50, panel_height: 120 },
        commands: { arrow_left: 50, arrow_top: 200, panel_height: 600 },
        guidelines: { arrow_left: 950, arrow_top: 200, panel_height: 250 },
        response: { arrow_left: 950, arrow_top: 480, panel_height: 500 }
      }
    
      def initialize
        @role = PanelOpts.new(:role, DEFAULT_OPTIONS[:role])
        @overview = PanelOpts.new(:overview, DEFAULT_OPTIONS[:overview])
        @commands = PanelOpts.new(:commands, DEFAULT_OPTIONS[:commands])
        @guidelines = PanelOpts.new(:guidelines, DEFAULT_OPTIONS[:guidelines])
        @response = PanelOpts.new(:response, DEFAULT_OPTIONS[:response])
      end
    
      def configure(panel_key, **opts)
        if respond_to?("#{panel_key}=")
          send("#{panel_key}=", PanelOpts.new(panel_key, opts))
        else
          puts "Panel key '#{panel_key}' is not supported."
        end
      end

      def debug
        role.debug
        overview.debug
        commands.debug
        guidelines.debug
        response.debug
      end
    end

    class BrandCategory
      attr_accessor :normal_text, :highlight_text

      def initialize(normal_text, highlight_text)
        @normal_text = normal_text
        @highlight_text = highlight_text
      end

      def mdx_component
        <<~MDX
        <BrandCategory>
          <span class="brand-text">#{normal_text} <highlight>#{highlight_text}</highlight></span>
        </BrandCategory>
        MDX
      end
    end

    # GptInstructionDsl is a DSL for chat GPT custom instructions.
    class GptInstructionDsl < KDirector::Directors::BaseDirector
      attr_accessor :instruction_name

      TOKEN_REGEX = /\[([^\]]+)\]/

      def default_template_base_folder
        'gpt-instruction'
      end

      def instruction(name, **opts, &block)
        builder.reset
        name = parse_name(name)
        title = (opts[:title] || name).to_s.gsub('_', ' ')
        builder.dom[:instruction] = { name: name, title: title }
        @instruction_name = name.to_s.gsub('_', '-')
        instance_eval(&block) if block_given?
        self
      end

      def panel(name, **opts, &block)
        current_panel = create_panel(name, **opts)
        builder.dom[:instruction][:panels] ||= []
        builder.dom[:instruction][:panels] << current_panel
        @current_panel = current_panel
        instance_eval(&block) if block_given?
        @current_panel = nil
        self
      end

      def panel_config
        @panel_config ||= PanelConfiguration.new
      end

      def panel_options(panel_key, title: nil, arrow_left: 50, arrow_top: 50, panel_height: 120)
        panel_key = parse_name(panel_key)
        title ||= panel_key.to_s.gsub('_', ' ')

        panel_config.configure(panel_key, title: title, arrow_left: arrow_left, arrow_top: arrow_top, panel_height: panel_height)
        self
      end

      def p(content)
        guard(:current_panel, "Must be inside a panel to add paragraph text.")
      
        if content_contains_tokens?(content)
          paragraph = { type: :paragraph, elements: process_elements(content) }
        else
          paragraph = { type: :paragraph, content: content }
        end
        
        @current_panel[:content] << paragraph
        self
      end
      
      def text(content)
        guard(:current_panel, "Must be inside a panel to add text.")
        content.split("\n").each do |line|
          p(line)
        end
        self
      end

      def command(name, description, shortcut: nil)
        guard(:current_panel, "Must be inside a panel to add commands.")
        command_hash = { type: :command, name: name }
      
        if content_contains_tokens?(description)
          command_hash[:elements] = process_elements(description)
        else
          command_hash[:description] = description
        end
      
        command_hash[:shortcut] = shortcut if shortcut
        @current_panel[:content] << command_hash
        self
      end

      def subtitle(text)
        guard(:current_panel, "Must be inside a panel to add subtitle.")
        subtitle_hash = { type: :subtitle, content: "#{text}:" }
        @current_panel[:content] << subtitle_hash
        self
      end

      def respond(name, description)
        guard(:current_panel, "Must be inside a panel to add responses.")
        response_hash = { type: :response, name: name }

        if content_contains_tokens?(description)
          response_hash[:elements] = process_elements(description)
        else
          response_hash[:description] = description
        end

        @current_panel[:content] << response_hash
        self
      end

      def save_json(file_name = nil, **opts)
        file_name ||= ':instruction_name'
        file_name = file_name.gsub(':instruction_name', @instruction_name) if @instruction_name
        file_name = "#{file_name}.json" unless file_name.end_with?('.json')

        add(file_name, content: JSON.pretty_generate(builder.dom), **opts)

        self
      end

      def save_mdx(file_name = nil, **opts)
        file_name ||= ':instruction_name'
        file_name = file_name.gsub(':instruction_name', @instruction_name) if @instruction_name
        file_name = "#{file_name}.mdx" unless file_name.end_with?('.mdx')

        astro = KDirector::Dsls::GptInstructionMdx.new(builder.dom).to_astro

        add(file_name, template_file: 'astro.mdx', components: astro, **opts)

        self
      end

      def osave_json(file_name = nil, **opts)
        save_json(file_name, **{ open: :write }.merge(opts))
      end

      def osave_mdx(file_name = nil, **opts)
        save_mdx(file_name, **{ open: :write }.merge(opts))
      end

      def copy_instruction
        extract_instruction_text(:to_gpt_instruction)
      end

      def copy_request
        extract_instruction_text(:to_request)
      end

      def copy_response
        extract_instruction_text(:to_response)
      end

      # facade methods
      # arrow_left: 50, arrow_top: 50, 
      def role(**opts, &block)
        opts = panel_config.role.clean_opts(opts)
        panel(opts[:name], **opts, &block)
      end
    
      def overview(**opts, &block)
        opts = panel_config.overview.clean_opts(opts)
        panel(opts[:name], **opts, &block)
      end
    
      def commands(**opts, &block)
        opts = panel_config.commands.clean_opts(opts)
        panel(opts[:name], **opts, &block)
      end
    
      def guidelines(**opts, &block)
        opts = panel_config.guidelines.clean_opts(opts)
        panel(opts[:name], **opts, &block)
      end
    
      def response(**opts, &block)
        opts = panel_config.response.clean_opts(opts)
        panel(opts[:name], **opts, &block)
      end

      def br(count = 1)
        count.times { p '&nbsp;' }
      end

      private

      def guard(condition_symbol, error_message)
        condition_value = instance_variable_get("@#{condition_symbol}")
        raise UsageError, error_message unless condition_value
      end

      # I added this so that I could use the DSL with just a title and it would configure correctly, I did this because I am demonstrating on video and I wanted a clean example.
      #
      # Given self.key == :todo_list_manager
      #
      # The old techniques were:
      # .instruction(self.key)
      # .instruction(self.key, 'Todo List Manager') do
      #
      # The new technique is:
      # .instruction('Todo List Manager')
      def parse_name(name)
        if name.is_a?(String) && name.include?(' ')
          name.gsub(' ', '_').to_sym
        else
          name.to_sym
        end
      end
    
      def content_contains_tokens?(content)
        content =~ TOKEN_REGEX
      end
      
      def process_elements(content)
        content.split(TOKEN_REGEX).each_slice(2).map do |span, token|
          elements = []
          elements << { span: span } unless span.strip.empty?
          
          unless token.nil?
            optional = token.end_with?('?')
            token_name = optional ? token[0..-2] : token  # Remove the '?' character
            elements << { token: { name: token_name, optional: optional } }
          end
          
          elements
        end.flatten
      end

      def create_panel(name, **opts)
        {
          type: :panel,
          name: name,
          title: opts[:title],
          content: [],
          arrow_left: opts[:arrow_left],
          arrow_top: opts[:arrow_top],
          panel_height: opts[:panel_height]
        }
      end

      def extract_instruction_text(method)
        data = builder.dom
        raw = KDirector::Dsls::GptInstructionRaw.new(data)
        content = raw.send(method)
        add_clipboard(content: content)
      end

      class UsageError < StandardError; end
    end
  end
end
