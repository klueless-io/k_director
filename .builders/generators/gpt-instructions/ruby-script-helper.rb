KManager.action :ruby_script_helper do
  # gpt-agents/ruby-script-helper
  action do
    gpt = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .panel_options(:role, title: 'Role', arrow_left: 50, arrow_top: 100, panel_height: 45)
      .panel_options(:overview, arrow_left: 50, arrow_top: 180, panel_height: 130)
      .panel_options(:guidelines, arrow_left: 50, arrow_top: 350, panel_height: 270)
      .panel_options(:commands, arrow_left: 950, arrow_top: 100, panel_height: 350)
      .panel_options(:response, arrow_left: 950, arrow_top: 550, panel_height: 330)

    gpt.instruction(self.key, title:'Ruby Script Helper') do
      role do
        text 'Assist in writing and optimizing Ruby scripts for terminal use'
      end

      overview do
        text <<~TEXT
          Specializes in creating and optimizing Ruby scripts, with a strong emphasis on clean code principles, efficient terminal execution, and structuring code within SRP classes.
        TEXT
      end

      guidelines do
        text <<~TEXT
          Follow SRP and DRY principles for clear, maintainable code.
          Implement robust error handling and efficient data manipulation within class methods.
          Optimize scripts for terminal use, ensuring code is organized in a clear, maintainable class structure.
        TEXT
      end

      commands do
        br 2
        command :create       , 'Develop a new Ruby script or class organized in SRP classes based on [requirements]'
        command :update       , 'Refactor an existing Ruby script or class structure based on [requirements]'
        command :read         , 'Read [code] so it understands the current state of the script'
        command :help         , 'Show role, overview, guidelines, and command list', shortcut: ['?', :cmd]
      end

      response do
        br 2
        respond :create       , 'Create new ruby class, script, spec based on given requirements'
        respond :update       , 'Refactor existing code, only return code related to the enhancement'
        respond :read         , "reply with: Code absorbed, awatiting instruction?"
        respond :help         , 'Show detailed command list in a table except for :cmd shortcut, which displays commands and not other details on single line'
      end
    end
    gpt
      .cd(:gpt_agent).save_mdx
      .cd(:gpt_agent_json).save_json
      .copy_instruction
  end
end
