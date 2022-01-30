# frozen_string_literal: true

class SampleBuilder < KDirector::Builders::ActionsBuilder; end

KBuilder.configure(:base_director_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
  # config.debug
end

RSpec.describe KDirector::Directors::BaseDirector do
  let(:instance) { described_class.new(k_builder, builder, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KBuilder.configuration(:base_director_spec)) }
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

      context 'when custom builder' do
        let(:builder) { SampleBuilder.new }

        it { is_expected.to be_a(SampleBuilder) }
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
    end

    describe '.on_action' do
      subject { instance.on_action }

      it { is_expected.to eq(:queue) }

      context 'when on_action provided' do
        let(:opts) { { on_action: :write } }

        it { is_expected.to eq(:write) }
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
        template_base_folder: ''
      )
    end

    context 'with custom options' do
      let(:custom_options) do
        {
          template_base_folder: 'xmen',
          on_exist: :write,
          on_action: :run
        }
      end
      it do
        is_expected.to include(
          on_exist: :write,
          on_action: :run,
          template_base_folder: 'xmen'
        )
      end
    end
  end

  context 'actions' do
    subject { instance.builder.last_action }

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
end
