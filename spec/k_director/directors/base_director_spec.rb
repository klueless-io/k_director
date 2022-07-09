# frozen_string_literal: true

class InsideBlock
  class << self
    attr_reader :name
  end

  class << self
    attr_writer :name
  end
end

class SampleBuilder < KDirector::Builders::ActionsBuilder; end

class SampleDirector < KDirector::Directors::BaseDirector
  default_builder_type(KDirector::Builders::DomBuilder)
end

class SampleDefaultOnExistDirector < KDirector::Directors::BaseDirector
  def default_on_exist
    :xmen
  end
end

class SampleDefaultOnActionDirector < KDirector::Directors::BaseDirector
  def default_on_action
    :ymen
  end
end

KConfig.configure(:base_director_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
  config.target_folders.add(:xmen, base_folder, 'xmen')
  # config.debug
end

RSpec.describe KDirector::Directors::BaseDirector do
  let(:instance) { described_class.new(k_builder, builder, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:base_director_spec)) }
  let(:builder) { KDirector::Builders::ActionsBuilder.new }
  let(:opts) { {} }

  describe '#init (factory method)' do
    let(:instance) { described_class.init(k_builder, builder, **opts) }
    let(:builder) { nil }

    describe '.k_builder' do
      subject { instance.k_builder }

      it { is_expected.to eq(k_builder) }
    end

    describe '.builder' do
      subject { instance.builder }
      context 'when default builder' do
        it { is_expected.to be_a(KDirector::Builders::ActionsBuilder) }
      end

      context 'when custom builder supplied in constructor' do
        let(:builder) { SampleBuilder.new }

        it { is_expected.to be_a(SampleBuilder) }
      end

      context 'when custom builder supplied via #default_builder_type' do
        let(:instance) { SampleDirector.init(k_builder) }

        it { is_expected.to be_a(KDirector::Builders::DomBuilder) }
      end
    end
  end

  describe 'initialize' do
    describe '.k_builder' do
      subject { instance.k_builder }

      it { is_expected.to eq(k_builder) }
    end

    describe '.builder' do
      subject { instance.builder }

      it { is_expected.to be_a(KDirector::Builders::ActionsBuilder) }
    end

    describe '.configuration' do
      subject { instance.configuration }

      it { is_expected.to be_a(KConfig::Configuration).and respond_to(:target_folders) }
    end

    describe '.active?' do
      subject { instance.active? }

      it { is_expected.to be_truthy }

      context 'when active is nil' do
        let(:opts) { { active: nil } }

        it { is_expected.to be_falsey }
      end

      context 'when active is false' do
        let(:opts) { { active: false } }

        it { is_expected.to be_falsey }
      end

      context 'when active is true' do
        let(:opts) { { active: true } }

        it { is_expected.to be_truthy }
      end
    end

    describe '.director_name' do
      subject { instance.director_name }

      it { is_expected.to eq('Base Director') }
    end

    describe '.template_base_folder' do
      subject { instance.template_base_folder }

      it { is_expected.to eq('') }

      context 'when template_base_folder provided' do
        let(:opts) { { template_base_folder: 'xmen' } }

        it { is_expected.to eq('xmen') }
      end
    end

    describe '.on_exist' do
      subject { instance.on_exist }

      it { is_expected.to eq(:skip) }

      context 'when on_exist provided' do
        let(:opts) { { on_exist: :write } }

        it { is_expected.to eq(:write) }
      end

      context 'when director implement default_on_exist' do
        let(:instance) { SampleDefaultOnExistDirector.init(k_builder) }

        it { is_expected.to eq(:xmen) }
      end
    end

    describe '.on_action' do
      subject { instance.on_action }

      it { is_expected.to eq(:queue) }

      context 'when on_action provided' do
        let(:opts) { { on_action: :write } }

        it { is_expected.to eq(:write) }
      end

      context 'when director implement default_on_action' do
        let(:instance) { SampleDefaultOnActionDirector.init(k_builder) }

        it { is_expected.to eq(:ymen) }
      end
    end
  end

  describe 'inherited_opts' do
    subject { instance.inherited_opts(**custom_options) }
    let(:custom_options) { {} }

    it do
      is_expected.to include(
        on_exist: :skip,
        on_action: :queue,
        template_base_folder: '',
        active: true
      )
    end

    context 'with custom options' do
      let(:custom_options) do
        {
          template_base_folder: 'xmen',
          on_exist: :write,
          on_action: :run,
          active: false
        }
      end
      it do
        is_expected.to include(
          on_exist: :write,
          on_action: :run,
          template_base_folder: 'xmen',
          active: false
        )
      end
    end
  end

  describe '#data' do
    subject { instance.dom }

    describe '#data' do
      context 'when simple key/values' do
        before { instance.data(a: 1, b: 2) }

        it { is_expected.to include(a: 1, b: 2) }

        describe '#typed_dom' do
          subject { instance.typed_dom }

          it { is_expected.to have_attributes(a: 1, b: 2) }
        end

        describe '#json_dom' do
          subject { instance.json_dom.squish }

          it { is_expected.to eq('{ "a": 1, "b": 2 }') }
        end

        context 'when key/values are nested' do
          before { instance.data(:child, a: 1, b: 2) }

          it { is_expected.to include(a: 1, b: 2, child: { a: 1, b: 2 }) }

          describe '#typed_dom' do
            subject { instance.typed_dom }

            it { is_expected.to have_attributes(a: 1, b: 2, child: have_attributes(a: 1, b: 2)) }
          end
        end
      end
    end

    describe '#settings (settings is an alias for #data with predefined name' do
      before { instance.settings(a: 1, b: 2) }

      it { is_expected.to include(settings: { a: 1, b: 2 }) }
    end
  end

  context 'actions' do
    subject { instance.builder.last_action }

    describe '#add' do
      before { instance.add(output_file, **opts) }

      let(:output_file) { 'output_file.txt' }
      let(:opts) { {} }

      it 'should have add_file action' do
        is_expected.to include(
          action: :add_file,
          file: output_file,
          opts: include(
            on_exist: :skip,
            template_file: output_file
          )
        )
      end

      context 'when opts[:template_base_folder] is set' do
        let(:opts) { { template_base_folder: 'xmen' } }

        it 'should have a custom template_file' do
          is_expected.to include(
            action: :add_file,
            file: output_file,
            opts: include(
              on_exist: :skip,
              template_file: 'xmen/output_file.txt'
            )
          )
        end
      end

      context 'when template_subfolder is set' do
        let(:opts) { { template_subfolder: 'subfolder' } }

        it 'should have a custom template tile' do
          is_expected.to include(
            action: :add_file,
            file: output_file,
            opts: include(
              on_exist: :skip,
              template_file: 'subfolder/output_file.txt'
            )
          )
        end
      end

      context 'when template_file is set' do
        let(:opts) { { template_file: 'template_file.txt' } }

        it 'should have a custom template file' do
          is_expected.to include(
            action: :add_file,
            file: output_file,
            opts: include(
              on_exist: :skip,
              template_file: 'template_file.txt'
            )
          )
        end

        context 'and template_subfolder is set' do
          let(:opts) do
            {
              template_file: 'template_file.txt',
              template_subfolder: 'subfolder'
            }
          end

          it 'should have a custom template file' do
            is_expected.to include(
              action: :add_file,
              file: output_file,
              opts: include(
                on_exist: :skip,
                template_file: 'subfolder/template_file.txt'
              )
            )
          end

          context 'and template_base_folder is set' do
            let(:opts) do
              {
                template_file: 'template_file.txt',
                template_subfolder: 'subfolder',
                template_base_folder: 'xmen'
              }
            end

            it 'should have a custom template file' do
              is_expected.to include(
                action: :add_file,
                file: output_file,
                opts: include(
                  on_exist: :skip,
                  template_file: 'xmen/subfolder/template_file.txt'
                )
              )
            end
          end
        end
      end
    end

    context 'when using quick overrides (#oadd, #tadd, #fadd)' do
      subject { instance.builder.last_action[:opts] }

      let(:output_file) { 'output_file.txt' }
      let(:opts) { {} }

      describe '#oadd (open the output file)' do
        before { instance.oadd(output_file, **opts) }

        it 'should open the output_file' do
          is_expected.to include(open: true)
        end
      end

      describe '#tadd (open the template file)' do
        before { instance.tadd(output_file, **opts) }

        it 'should open the template_file' do
          is_expected.to include(open_template: true)
        end
      end

      describe '#fadd (force write the output file)' do
        before { instance.fadd(output_file, **opts) }

        it 'should open the template_file' do
          is_expected.to include(on_exist: :write)
        end
      end
    end

    describe '#add_file' do
      before { instance.add_file('david.txt') }

      it do
        is_expected.to include(
          action: :add_file,
          played: false,
          file: 'david.txt',
          opts: { on_exist: :skip, dom: {} }
        )
      end
    end

    describe '#add_clipboard' do
      before { instance.add_clipboard }

      it do
        is_expected.to include(
          action: :add_clipboard,
          played: false,
          opts: {}
        )
      end
    end

    describe '#set_current_folder_action' do
      subject { instance.builder.last_action }

      before { instance.set_current_folder_action(:app) }

      it do
        # puts JSON.pretty_generate(subject)
        is_expected.to include(
          action: :set_current_folder,
          played: false,
          folder_key: :app
        )
      end
    end

    describe '#run_command' do
      subject { instance.builder.last_action }

      before { instance.run_command('echo david') }

      it do
        is_expected.to include(
          action: :run_command,
          played: false,
          command: 'echo david'
        )
      end
    end

    describe '#run_script' do
      subject { instance.builder.last_action }

      before { instance.run_script('echo david') }

      it do
        is_expected.to include(
          action: :run_script,
          played: false,
          script: 'echo david'
        )
      end
    end
  end

  context 'child directors' do
    subject { instance }

    describe '#github' do
      it { is_expected.to respond_to(:github) }

      context 'when block given' do
        subject { InsideBlock.name }

        before do
          InsideBlock.name = nil
          instance.github { |_| InsideBlock.name = 'github' }
        end

        it { is_expected.to eq('github') }

        context 'when option active is false' do
          let(:opts) { { active: false } }

          it { is_expected.to eq(nil) }
        end
      end
    end

    describe '#package_json' do
      it { is_expected.to respond_to(:package_json) }

      context 'when block given' do
        subject { InsideBlock.name }

        before do
          InsideBlock.name = nil
          instance.package_json { |_| InsideBlock.name = 'package_json' }
        end

        it { is_expected.to eq('package_json') }

        # context 'when option active is false' do
        #   let(:opts) { { active: false } }

        #   it { is_expected.to eq(nil) }
        # end
      end
    end

    describe '#blueprint' do
      it { is_expected.to respond_to(:blueprint) }

      context 'when block given' do
        subject { InsideBlock.name }

        before do
          InsideBlock.name = nil
          instance.blueprint { |_| InsideBlock.name = 'blueprint' }
        end

        it { is_expected.to eq('blueprint') }

        context 'when option active is false' do
          let(:opts) { { active: false } }

          it { is_expected.to eq(nil) }
        end
      end
    end
  end

  context 'SCENARIOS' do
    before do
      Handlebars::Helpers.configure do |config|
        config.helper_config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_helpers.json')
        config.string_formatter_config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_string_formatters.json')
      end

      instance.set_current_folder_action(:app)

      # touch a file
      instance.add_file('sample.txt')

      # create file using template_file
      instance.add_file('sample-2.txt',
                        template_file: 'sample.txt',
                        name: 'sample-2')

      # create file in different folder using template_file
      instance.add_file('sample-3.txt',
                        template_file: 'sample.txt',
                        name: 'xman',
                        folder_key: :xmen)

      # create file using inline template
      instance.add_file('sample-4.txt',
                        template: 'I am custom template, hello {{name}}',
                        name: 'david')

      # create file using content
      instance.add_file('sample-5.txt',
                        content: 'I am custom content')

      instance.data(
        first_name: 'John',
        last_name: 'Doe'
      )

      instance.data(:something_complex,
                    key: 'test-1',
                    names: %w[john lisa mike])

      instance.add_file('sample-6.txt',
                        template: "I am custom template\nhello {{dom.first_name}} {{dom.last_name}}\nkey: {{dom.something_complex.key}}\nnames: {{dom.something_complex.names}}")

      instance.run_command('echo david')
      instance.run_script('echo david')
    end

    # fit '#scenario_1' do
    #   # config = KConfig.configuration(:base_director_spec)
    #   # config.debug
    #   # instance.debug
    #   # instance.builder.debug
    #   # config.target_folders.debug
    #   # instance.play_actions
    #   # instance.k_builder.run_script("code .")
    #   # sleep 3
    # end
  end
end
