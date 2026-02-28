# Text is just a short cut to multiple p calls

KManager.action :astrojs_tailwind do
  action do
    # Add support for:
    #   Chat URLS that can take me to GPT chatbots related to the GPT Custom Instruction
    #   Panels called ai_role, commands, overview, guidelines, response
    #   HTML hover for request and response
    #   Click to copy content to clipboard
    #   Glow focus around panels
    #   Add support for anchor links in a bold brown color
    #   Add support for panel heights into instruction or config method
    director = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .instruction(self.key, title: 'AstroJS / TailwindCSS') do
        panel :ai_role, arrow_left: 50, arrow_top: column1_top.ai_role do
          p       'AstroJS 3.0 / TailwindCSS Expert'
        end

        panel :commands, arrow_left: 50, arrow_top: 200, panel_height: panel_height.commands do
          p                     'Command access is by name or alias'
          p '&nbsp;'
          command :help,        'Show role, list of commands, overview of how you work.'
          command :goal,        '[goal] this is what I want to accomplish'
          command :astro,       '[description|paramaters] create an component'
          command :css,         '[description] give tailwind css classes'
          command :js,          '[description] generate javascript to use in the Astro component'
          command :code,        '[code] this is the code I want to work on'
          command :pattern,     '[pattern] of code that I like to use'
          command :status,      'Show command names and the current list name'
        end

        panel :overview, arrow_left: 950, arrow_top: column2_top.overview, panel_height: panel_height.overview do
          text <<~TEXT
            You will help me build a website using AstroJS 3.0 and TailwindCSS.
          TEXT
        end

        panel :guidelines, arrow_left: 950, arrow_top: column2_top.guidelines, panel_height: panel_height.guidelines do
          text <<~TEXT
            Use Bing to lookup current information on AstroJS 3.0 and TailwindCSS.
            https://astro.build/blog/astro-3/
            https://tailwindcss.com/
          TEXT
        end

        panel :response, arrow_left: 950, arrow_top: column2_top.response, panel_height: panel_height.response do
          p       'Show STATUS after each command except HELP.'
          p '&nbsp;'
          respond :astro      , 'Create an Astro component based on [description] or [parameters]'
          respond :css        , 'Give me tailwind css classes based on [description]'
          respond :js         , 'Generate javascript code based on [description]'
          respond :code       , 'Focus on [code] block which could [astro|tailwind|javascript]'
          respond :pattern    , 'Remember this code [pattern] this is my opinionated way of letting you know my code preferences'
          respond :status     , 'List command names in bold on a single line'
          respond :help       , 'Show role, list of commands, overview of how you work.'
          p       'For [code and pattern] just give me a 15 word summary'
        end
      end

      director
        .cd(:gpt_agent).save_mdx
        .cd(:gpt_agent_json).save_json
        
      data = director.builder.dom

      # puts JSON.pretty_generate(data)
      raw = KDirector::Dsls::GptInstructionRaw.new(data)
      # puts raw.to_request
      puts raw.to_gpt_agent
  end

end

# Structure for the heights
Height = Struct.new(:ai_role, :overview, :commands, :guidelines, :response, keyword_init: true)
Column1_top = Struct.new(:ai_role, :commands, keyword_init: true)
Column2_top = Struct.new(:overview, :guidelines, :response, keyword_init: true)

def column1_top
  @column1_top ||= begin
    gap = 50
    panel1_y = 50
    panel2_y = panel1_y + panel_height.ai_role + gap

    @column1_top ||= Column1_top.new(ai_role: panel1_y, commands: panel2_y)
  end
end

def column2_top
  @column2_top ||= begin
    gap = 30
    panel1_y = 50
    panel2_y = panel1_y + panel_height.overview + gap
    panel3_y = panel2_y + panel_height.guidelines + gap

    @column2_top ||= Column2_top.new(overview: panel1_y, guidelines: panel2_y, response: panel3_y)
  end
end

def panel_height
  @panel_height ||= Height.new(
    ai_role: 50,
    overview: 120,
    commands: 480,
    guidelines: 150,
    response: 480
  )
end
