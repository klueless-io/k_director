module KDirector
  module Dsls
    # Takes the GPT instruction JSON and converts to raw text for pasting 
    # into GPT-Plus Custom Instruction Fields.
    # 
    # There is a request field and a response field.
    # 
    #  Example
    # 
    #  Role: ToDo List Manager
    #
    # You will maintain my ToDo lists. 
    # You will keep different lists.
    # I want to add, view and mark as complete items on my todo list.
    # 
    # Commands:
    # 
    # Any parameter with ? is optional.
    # Command access is by name or alias
    # 
    # HELP: Show role, list of commands, overview of how you work.
    # SET: [name] - set the current list, create new list if it doesn't exist
    # ADD|A: [name?] [item] - add an item to the list [on day]
    # DONE|D: [name?] [item] - to remove an item from the list, I may only give you the first one or two words when removing.
    # LIST|L: show all todo lists
    # TODO|T: [name?] - show me items to do on a list
    # UP: [name?] [item|number] - move an item up in the list
    # DOWN: [name?] [item|number] - move an item down in the list
    # CLEAR: [name?] - clear all items from a list
    # STATUS: Show command names and the current list name
    # 
    # Guidelines:
    # 
    # Assign numbers to each list item so I can refer to them by number.
    # [name?] is optional, if I don't give you a name, you should use the current list.
    # If I give you a day [Mon, Tuesday, Wed etc…, it goes into the Day of Week and not the Task Name field.
    # 
    # Schema: 
    # List [List Name, Task Count]
    # ToDo [Task Name, Day of Week, Completed]
    # 
    # 
    # Response:
    # 
    # LIST: Display todo list names and number of tasks in table format
    # TODO: Display todo list items in table format, with numbers and checkboxes
    # ADD|DONE|TODO|UP|DOWN: If list name is not provided then act against the current focus list.
    # STATUS: Display command names and aliases in bold on one line and also report what the current focus list is.
    # Show STATUS after each command except HELP.

    class GptInstructionRaw

      def initialize(json_hash)
        @json_hash = json_hash
      end

      def to_gpt_instruction
        "#{to_request}\n\nResponse style for commands and questions:\n#{to_response}"
      end

      def to_request
        cleanup_double_line_breaks(request_text)
      end

      def to_response
        cleanup_double_line_breaks(response_text)
      end

      private

      def request_text
        [
          process_panel(:role),
          '',
          process_panel(:overview),
          '',
          process_panel(:commands, heading: 'Commands:'),
          '',
          process_panel(:guidelines, heading: 'Guidelines:'),
        ].flatten.join("\n").gsub('**', '').gsub('  ', ' ').gsub(' ,', ',')
      end

      def response_text
        [
          process_panel(:response),
        ].flatten.join("\n").gsub('**', '').gsub('  ', ' ').gsub(' ,', ',')
      end

      def panels
        @json_hash[:instruction][:panels]
      end

      def panel(panel_name)
        return nil unless panels
        panels.find { |p| p[:name] == panel_name }
      end

      def process_panel(panel_name, heading: nil)
        panel = panel(panel_name)
        return unless panel

        lines = panel[:content].map do |content_item|
          if content_item[:type] == :paragraph
            process_paragraph(content_item)
          elsif content_item[:type] == :subtitle
            content_item[:content]
          elsif content_item[:type] == :command || content_item[:type] == :response
            process_command(content_item)
          end
        end
      
        lines.compact!

        if heading && lines.length > 0
          lines.unshift(heading)
        end

        lines
      end

      def process_paragraph(content_item)
        if content_item[:content]
          return nil if content_item[:content] == "&nbsp;"
          content_item[:content]
        elsif content_item[:elements]
          process_elements(content_item[:elements])
        end
      end

      def process_elements(elements)
        elements.map do |element|
          if element[:span]
            element[:span]
          elsif element[:token]
            optional = element[:token][:optional] ? '?' : ''
            "[#{element[:token][:name]}#{optional}]"
          end
        end.join(' ')
      end

      # examples:
      # command :help       , 'Show role, overview, guidelines, and list of commands', shortcut: ['?', :cmd, :commands]
      # command :definition , 'Show definition of [word]', shortcut: :def
      def process_command(command)
        shortcut = build_shortcut(command[:shortcut])
        description = command[:description] || format_elements(command[:elements])
        "#{command[:name]&.upcase}#{shortcut}: #{description}"
      end

      def build_shortcut(shortcut)
        return '' unless shortcut
        return "|#{shortcut.upcase}" unless shortcut.is_a?(Array)

        shortcut.map { |s| "|#{s.upcase}" }.join('')
      end

      def format_elements(elements)
        return '' unless elements
      
        elements.map do |element|
          if element[:span]
            element[:span]
          elsif element[:token]
            optional = element[:token][:optional] ? '?' : ''
            "[#{element[:token][:name]}#{optional}]"
          end
        end.join(' ')
      end

      def add_extra_line(text)
        "#{text}\n" unless text.empty?
      end

      def cleanup_double_line_breaks(text)
        text.gsub("\n\n\n", "\n\n")
      end
    end
  end
end
