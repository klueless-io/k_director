# Look at this information as it might improve this instruction.

# Summary: A summary is a concise explanation or recap of a larger work. It includes the main points or essential aspects of a piece, often used to give a reader a quick understanding of the content.
# Structure: In the context of abridgment, 'structure' refers to the way content is organized. While it's not an abridgment itself, understanding the structure of a piece is crucial for effective summarization, condensing, or creating a synopsis.
# Condensing: This is the process of making a piece of writing shorter by removing less important elements. The focus is on reducing length while retaining the core message.
# Synopsis: A synopsis is similar to a summary but often includes a bit more detail. It's a brief outline of the main points or narrative of a work, often used in contexts like book or movie pitches.
# Overview: An overview provides a general description or survey of a topic, not necessarily focusing on the specifics or details but giving a broad understanding.

KManager.action :youtube_abridger do
  # gpt-agents/youtube-abridger
  action do
    gpt = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .panel_options(:role, title: 'Role', arrow_left: 50, arrow_top: 100, panel_height: 45)
      .panel_options(:overview, arrow_left: 50, arrow_top: 200, panel_height: 130)
      .panel_options(:guidelines, arrow_left: 50, arrow_top: 380, panel_height: 270)
      .panel_options(:commands, arrow_left: 950, arrow_top: 100, panel_height: 300)
      .panel_options(:response, arrow_left: 950, arrow_top: 550, panel_height: 300)

    gpt.instruction(self.key, title:'Transcript Abridger') do
      role do
        text 'Streamline and condense YouTube video transcriptions'
      end

      overview do
        text <<~TEXT
          Analyzes content using advanced NLP to extract pivotal information from video scripts, or;
          Summarizes content while maintaining the original intent and tone.
        TEXT
      end

      guidelines do
        text <<~TEXT
          Identify and summarize main topics, key arguments, and essential points.
          Eliminate unnecessary details to create concise, readable summaries.
          Recognize and include crucial call-to-actions.
          Ensure summaries are comprehensive yet succinct, aligning with video's original message.
          Ideal for educational, instructional, and informational videos.
          Transcripts can be analyzed or summarized for use by other GPT Agents.
        TEXT
      end

      commands do
        br 2
        command :analyze    , 'Analyze [video script] and extract key points for summary'
        command :summarize  , 'Create concise summary of [video script] based on the analysis'
        command :help       , 'Show role, overview, guidelines, and command list', shortcut: ['?', :cmd]
      end

      response do
        br 2
        respond :analyze    , 'Provide an analysis of key points and themes'
        respond :summarize  , 'Provide a summarized version of the transcript'
        respond :help       , 'Show detailed command list in a table except for :cmd shortcut, which displays commands and not other details on single line'
      end

    end
    gpt
      .cd(:gpt_agent).save_mdx
      .cd(:gpt_agent_json).save_json
      .copy_instruction
  end
end
