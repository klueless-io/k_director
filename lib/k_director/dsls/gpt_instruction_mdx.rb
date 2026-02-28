module KDirector
  module Dsls
    class GptInstructionMdx
      def initialize(json_hash)
        @json_hash = json_hash
      end

      def to_astro
        return '' unless @json_hash[:instruction] && @json_hash[:instruction][:panels]
        panels = @json_hash[:instruction][:panels].map do |panel|
          generate_panel(panel, 0)
        end.join("\n")

        <<~ASTRO
          #{panels}
        ASTRO
      end

      private

      def escape_single_quotes(value)
        value.to_s.gsub("'", "&apos;")
      end

      def indent(level)
        '  ' * level
      end

      def generate_panel(panel, level)
        arrow_left = panel[:arrow_left] ? " arrow_left='#{panel[:arrow_left]}'" : ''
        arrow_top = panel[:arrow_top] ? " arrow_top='#{panel[:arrow_top]}'" : ''
        panel_height = panel[:panel_height] ? " panel_height='#{panel[:panel_height]}'" : ''

        content_lines = panel[:content].map do |item|
          generate_content(item, level + 1)
        end.flatten

        [
          "#{indent(level)}<Panel label='#{panel[:title]}'#{arrow_left}#{arrow_top}#{panel_height}>",
          *content_lines,
          "#{indent(level)}</Panel>"
        ]
      end

      def generate_subtitle(item, level)
        lines = [
          "#{indent(level)}<p class='mb-2 font-bold'>#{item[:content]}</p>"
        ]
      end

      def generate_paragraph(item, level)
        return generate_paragraph_simple(item, level) if item[:content]
        return generate_paragraph_elements(item, level) if item[:elements]

        []
      end

      def generate_paragraph_simple(item, level)
        lines = [
          "#{indent(level)}<p class='mb-2'>#{item[:content]}</p>"
        ]
      end

      def param(param_name, optional = nil)
        "<Param name='#{escape_single_quotes(param_name)}#{optional}' />"
      end

      def generate_paragraph_elements(item, level)
        parts = ["#{indent(level)}<p class='mb-2'>"]

        elements = item[:elements].map do |element|
          if element[:span]
            parts << "#{escape_single_quotes(element[:span])} "
          elsif element[:token]
            param_name = element[:token][:name]
            optional = element[:token][:optional] ? '?' : ''
            parts << param(param_name, optional)
          end
        end

        parts << '</p>'

        [parts.join]
      end

      def generate_command(item, level)
        lines = []
        shortcut = item[:shortcut] ? " alias='#{item[:shortcut]}'" : ''
        lines << "#{indent(level)}<Command name='#{item[:name].upcase}'#{shortcut}>"
      
        if item[:description].is_a?(String)
          lines << "#{indent(level+1)}<p>#{item[:description]}</p>"
        elsif item[:elements].is_a?(Array)
          lines << "#{indent(level+1)}<p>"
          item[:elements].each do |element|
            if element[:span]
              lines << "#{indent(level+2)}<span>#{escape_single_quotes(element[:span])}</span> "
            elsif element[:token]
              param_name = element[:token][:name]
              optional = element[:token][:optional] ? '?' : ''
              lines << "#{indent(level+2)}#{param(param_name, optional)}"
              # lines << "#{indent(level+1)}<Param name='#{escape_single_quotes(param_name)}#{optional}' />"
            end
          end
          lines << "#{indent(level+1)}</p>"
        end
      
        lines << "#{indent(level)}</Command>"
        
        lines
      end

      def generate_response(item, level)
        lines = []
        lines << "#{indent(level)}<Response name='#{escape_single_quotes(item[:name])}' description='#{escape_single_quotes(item[:description])}' />"
        lines
      end

      def generate_content(item, level)
        case item[:type]
        when :paragraph
          generate_paragraph(item, level)
        when :subtitle
          generate_subtitle(item, level)
        when :command, :response
          generate_command(item, level)
        else
          []
        end
      end
    end
  end
end
