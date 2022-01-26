
KManager.action :bootstrap do
  def on_action
    application_name = :k_director
    director = Dsl::RubyGemDsl
      .init(k_builder,
        template_base_folder:       'ruby/gem',
        on_exist:                   :skip,                      # %i[skip write compare]
        on_action:                  :queue,                     # %i[queue execute]
        ruby_version:               '2.7',
        repo_name:                  application_name,
        application:                application_name,
        application_description:    'KDirector provides domain specific language implementations for code generation',
        application_lib_path:       application_name.to_s,
        application_lib_namespace:  'KDirector',
        namespaces:                 ['KDirector'],
        author:                     'David Cruwys',
        author_email:               'david@ideasmen.com.au',
        avatar:                     'Developer',
        initial_semver:             '0.0.13',
        main_story:                 'As a Developer, I want to generate code using a DSL, so that I can speed up application development',
        copyright_date:             '2022',
        website:                    'http://appydave.com/gems/k_director'
      )
      .github do
        parent.options.repo_info = repo_info

        # create_repository # (:k_director)
        # delete_repository # (:k_director)
        # list_repositories
        # open_repository # (:k_director)
        # run_command('git init')
      end
      .blueprint(
        name: :bin_hook,
        description: 'BIN/Hook structures',
        on_exist: :compare) do

        cd(:app)
        self.dom = OpenStruct.new(parent.options.to_h.merge(options.to_h))

        # # add('bin/runonce/git-setup.sh', dom: dom)
        run_template_script('bin/runonce/git-setup.sh', dom: dom)

        # add('.githooks/commit-msg') #, template_subfolder: 'ruby', template_file: 'commit-msg')
        # add('.githooks/pre-commit') #, template_subfolder: 'ruby', template_file: 'pre-commit')

        # run_command('chmod +x .githooks/commit-msg')
        # run_command('chmod +x .githooks/pre-commit')

        # add('.gitignore')

        # add('bin/setup')
        # add('bin/console')

        # # enable sharable githooks (developer needs to turn this on before editing rep)
        # run_command('git config core.hooksPath .githooks')

        # run_command("git add .; git commit -m 'chore: #{self.options.description.downcase}'; git push")
      end
      .blueprint(
        name: :opinionated,
        description: 'opinionated GEM files',
        on_exist: :write) do

        cd(:app)
        self.dom = OpenStruct.new(parent.options.to_h.merge(options.to_h))

        # add("lib/#{dom.application}.rb"             , template_file: 'lib/applet_name.rb'         , dom: dom)
        # add("lib/#{dom.application}/version.rb"     , template_file: 'lib/applet_name/version.rb' , dom: dom)
    
        # add('spec/spec_helper.rb')
        # add("spec/#{dom.application}_spec.rb"       , template_file: 'spec/applet_name_spec.rb', dom: dom)

        # add("#{dom.application}.gemspec"            , template_file: 'applet_name.gemspec', dom: dom)
        # add('Gemfile', dom: dom)
        # add('Guardfile', dom: dom)
        # add('Rakefile', dom: dom)
        # add('.rspec', dom: dom)
        # add('.rubocop.yml', dom: dom)
        # add('README.md', dom: dom)
        # add('docs/CODE_OF_CONDUCT.md', dom: dom)
        # add('docs/LICENSE.txt', dom: dom)

        # run_command("rubocop -a")
      
        # run_command("git add .; git commit -m 'chore: #{self.options.description.downcase}'; git push")
      end
      .blueprint(
        name: :ci_cd,
        description: 'github actions (CI/CD)',
        on_exist: :write) do

        cd(:app)
        self.dom = OpenStruct.new(parent.options.to_h.merge(options.to_h))

        # run_command("gh secret set SLACK_WEBHOOK --body \"$SLACK_REPO_WEBHOOK\"")
        # run_command("gh secret set GEM_HOST_API_KEY --body \"$GEM_HOST_API_KEY\"")
        # add('.github/workflows/main.yml')
        # add('.github/workflows/semver.yml')
        # add('.releaserc.json')

        # run_command("git add .; git commit -m 'chore: #{self.options.description.downcase}'; git push")
      end

    # director.k_builder.debug
    director.play_actions
    # director.builder.logit
  end
end
