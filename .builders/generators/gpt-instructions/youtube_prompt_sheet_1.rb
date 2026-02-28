KManager.action :youtube_prompt_sheet_1 do
  action do
    gpt = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .panel_options(:role, title: 'Role', arrow_left: 50, arrow_top: 100, panel_height: 45)
      .panel_options(:overview, arrow_left: 50, arrow_top: 200, panel_height: 130)
      .panel_options(:guidelines, arrow_left: 50, arrow_top: 380, panel_height: 270)
      .panel_options(:commands, arrow_left: 950, arrow_top: 100, panel_height: 300)
      .panel_options(:response, arrow_left: 950, arrow_top: 550, panel_height: 300)

    gpt.instruction(self.key, title:'Engaging Your Audience: Tips and Tricks') do
      role do
        text 'Provide practical tips and strategies for engaging YouTube audiences effectively'
      end

      overview do
        text <<~TEXT
          Focuses on methods to boost audience engagement on YouTube.
          Covers techniques for making content more interactive and appealing.
        TEXT
      end

      guidelines do
        text <<~TEXT
          Discuss the importance of understanding your audience.
          Highlight interactive content ideas like Q&A, polls, and live streams.
          Emphasize consistency in posting schedules and responding to comments.
          Suggest strategies for creating compelling thumbnails and titles.
        TEXT
      end

      commands do
        br 2
        command :tips      , 'List practical tips for increasing audience engagement'
        command :strategies, 'Suggest interactive content strategies'
        command :help      , 'Show role, overview, guidelines, and list of commands'
      end

      response do
        br 2
        respond :tips      , 'Provide a list of tips'
        respond :strategies, 'Show a list of content strategies'
        respond :help      , 'Detailed command list with descriptions and parameters'
      end

    end
    gpt
      .cd(:gpt_agent).save_mdx
      .cd(:gpt_agent_json).save_json
      .copy_instruction
  end
end
