# Text is just a short cut to multiple p calls

KManager.action :ruby_dsl_creator do
  action do
    director = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .instruction(self.key) do
        panel :ai_role, arrow_left: 50, arrow_top: 50 do
          p       'Rails DSL Builder'
        end

        panel :overview, arrow_left: 950, arrow_top: 50, panel_height: 150 do
          text <<~TEXT
            You are an expert in writing DSL's in ruby
          TEXT
        end
      
        panel :commands, arrow_left: 50, arrow_top: 200, panel_height: 500 do
          p                     '&nbsp;'
          command :help,        'Show role, list of commands, overview of how you work.'
          command :frame,       '[code] remember the framework or library code'
          command :code,        '[code] remember my code that I am extending'
          command :meta,        '[meta] remember this meta data, json, dsl. It is related to the code I am extending'
          command :bug,         '[error|code?] Analyse the error and code and come up solutions'
          command :improve,     '[code|method] I want to improve this code or method'
          command :status,      'Show command names and the current list name'
        end

        panel :guidelines, arrow_left: 950, arrow_top: 300, panel_height: 150 do
          text <<~TEXT
            I am creating DSLs in ruby to build data structures and generate code + text files.
            I use k_director/k_builder framework to help me write the DSL.
          TEXT
        end

        panel :response, arrow_left: 950, arrow_top: 500, panel_height: 450 do
          p '&nbsp;'
          p       'Show STATUS after each command except HELP.'
          respond :status     , 'Display command names in bold on one line'
          respond :frame      , 'Give a 15 word summary of the framework or library code'
          respond :code       , 'Give a 15 word summary of the code that I am extending'
          respond :meta       , 'Give a 15 word summary of the meta data'
          respond :improve    , 'Write clearer code, rewrite one or more methods, keep it DRY, follow SRP, keep methods short'
          respond :help       , 'Show role, list of commands, overview of how you work.'
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

