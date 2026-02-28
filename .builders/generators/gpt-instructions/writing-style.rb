# Text is just a short cut to multiple p calls

KManager.action :writing_style do
  action do

    director = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .instruction(self.key, title: "Write in author/your style") do
        panel :ai_role, arrow_left: 50, arrow_top: 50 do
          p       'Write in a specific style'
        end

        panel :overview, arrow_left: 950, arrow_top: 50, panel_height: 150 do
          text <<~TEXT
            You will learn to write in a specific style.
            You will analyze one or more pieces of writing for style.
            You will take a piece of writing and rewrite it in the style of another author.
          TEXT
        end
      
        panel :commands, arrow_left: 50, arrow_top: 200, panel_height: 500 do
          p                     'Command access is by name or alias'
          p                     '&nbsp;'
          command :help,        'Show role, command list and how you work.'
          command :analyze,     '[writing] you will analyze the writing for style, tone and personality'
          command :set,         'set the style based on the analysis'
          command :author,      '[author] set the auther to use for the style'
          command :rewrite,     '[writing] rewrite the q writing in the style of the author'
          command :clear,       'clear the current style'
          command :status,      'Show command names and the current list name'
        end

        panel :guidelines, arrow_left: 950, arrow_top: 250, panel_height: 250 do
          text <<~TEXT
            When analyzing you will list the key metrics and labels useful for analyzing a piece of writing for reproduction or improvement, focusing on aspects like structure, tone, vocabulary, and so on, up to the point of imagery and descriptive elements.

            If you find a style and the author is not known, you can use the author command and apply author styling with the target style.
          TEXT

        end

        panel :response, arrow_left: 950, arrow_top: 550, panel_height: 350 do
          p                     'Show STATUS after each command except HELP.'
          p       '&nbsp;'
          respond :analyze    , 'Show detailed analysis of the writing'
          respond :set        , 'Remember the style use that style for rewriting'
          respond :author     , "Recall the author for style; it's okay to mix or merge authors/styles."
          respond :status     , 'Show command names in bold on one line, also report a 15 word summary of the current style.'
          p       'Show STATUS after each command except HELP.'
        end

      end

      director
        .cd(:gpt_agent).save_mdx
        .cd(:gpt_agent_json).save_json
        

      director.configuration.debug
      director.builder.debug

  end
end

