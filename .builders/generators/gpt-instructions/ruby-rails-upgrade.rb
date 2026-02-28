KManager.action :ruby_rails_upgrade do
  action do
    gpt = KDirector::Dsls::GptInstructionDsl
      .init(k_builder, on_exist: :write, on_action: :execute)
      .panel_options(:role, title: 'AI Role', arrow_left: 50, arrow_top: 50, panel_height: 70)
      .panel_options(:commands, arrow_left: 50, arrow_top: 200, panel_height: 600)
      .panel_options(:overview, arrow_left: 950, arrow_top: 50, panel_height: 220)
      .panel_options(:guidelines, arrow_left: 950, arrow_top: 300, panel_height: 250)
      .panel_options(:response, arrow_left: 950, arrow_top: 700, panel_height: 350)

    gpt.instruction(self.key) do
      role do
        text    'Rails Upgrade Helper'
      end

      overview do
        text <<~TEXT
          Help me migrate rails 6.0 to 6.1 and 7.1 using bash and ruby scripts.
          Goal is to move 7000 files from old to new
          Some files will need to be modified before moving.
          You will help me write the scripts and rules so I have flexibility to skip, clone, remove or modify files.
        TEXT
      end

      commands do
        br 2
        command :help,        'Show role, list of commands, overview of how you work.'
        command :develop,     '[code] Develop or modify code based on given instructions.', shortcut: :code
        command :base,        '[code] this is the existing code base'
        command :qXX,         'Answer a question about the provided Rails version, XX = 61, 70 or 71'
        command :status,      'Show command names and the current list name'
      end

      guidelines do
        text <<~TEXT
          [source_dir] Path to existing Rails application to be upgraded.
          [target_dir] Path to new Rails application version (6.1 or 7.1).
          [custom_dir] Path where code customizations are.
          [csv_file] CSV file with rules for copying files from the source to the target.
          [override_csv_file] CSV file for custom rules for specific files.
        TEXT
      end

      response do
        br 2
        respond :qXX        , 'The question is about the provided Rails version, which will be in the format 61, 70 or 71 for Rails 6.1, 7.0 and 7.1.'
        respond :status     , 'Display command names in bold on one line'
        respond :help       , 'Show role, list of commands, overview of how you work.'
        text    'Show STATUS after each command except HELP.'
      end
    end

    gpt
      .cd(:gpt_agent).save_mdx
      .cd(:gpt_agent_json).save_json
      .copy_instruction

  end
end

