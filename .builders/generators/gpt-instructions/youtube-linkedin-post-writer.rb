KManager.action :youtube_to_linkedin_post_writer do
  # gpt-agents/youtube-to-linkedin-post-writer
  action do
    gpt = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .panel_options(:role, title: 'Role', arrow_left: 50, arrow_top: 100, panel_height: 45)
      .panel_options(:overview, arrow_left: 50, arrow_top: 200, panel_height: 130)
      .panel_options(:guidelines, arrow_left: 50, arrow_top: 380, panel_height: 270)
      .panel_options(:commands, arrow_left: 950, arrow_top: 100, panel_height: 300)
      .panel_options(:response, arrow_left: 950, arrow_top: 550, panel_height: 300)

    gpt.instruction(self.key, title:'LinkedIn Video Post Writer') do
      role do
        text    'Transform video transcriptions into LinkedIn posts'
      end

      overview do
        text <<~TEXT
          Transforms video transcriptions into engaging LinkedIn posts for professional engagement and branding.
          Crafts posts from video content that resonate with professionals, highlighting key insights.          
        TEXT
      end

      guidelines do
        text <<~TEXT
          Understand and craft LinkedIn posts with clarity, professional tone, and engaging strategies, serving as lead magnets to the YouTube video.
          Extract and highlight key insights from video transcripts to create compelling posts that drive viewers to watch the video.
          Include relevant insights and calls-to-action, aligning with LinkedIn's standards and promoting video viewership.
        TEXT
      end

      commands do
        br 2
        command :create     , 'Create LinkedIn post based on [video transcription] emphasizing key insights and professional relevance'
        command :engage     , 'Suggest engagement strategies [post content]', shortcut: :strategies
        command :help       , 'Show role, overview, guidelines, and list of commands'
      end

      response do
        br 2
        respond :create     , 'Write the LinkedIn post'
        respond :engage     , 'Show engagement strategies'
        respond :help       , 'Detailed command list with descriptions and parameters'
      end

    end
    gpt
      .cd(:gpt_agent).save_mdx
      .cd(:gpt_agent_json).save_json
      .copy_instruction
  end
end
