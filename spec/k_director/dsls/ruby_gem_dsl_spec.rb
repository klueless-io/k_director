# frozen_string_literal: true

KConfig.configure(:ruby_gem_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
  config.target_folders.add(:xmen, base_folder, 'xmen')
end

RSpec.describe KDirector::Dsls::RubyGemDsl do
  let(:director) { described_class.init(k_builder, nil, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:base_director_spec)) }
  let(:opts) { {} }

  describe 'initialize' do
    describe '.k_builder' do
      subject { director.k_builder }

      it { is_expected.to eq(k_builder) }
    end
  end

  describe '.template_base_folder' do
    subject { director.template_base_folder }

    it { is_expected.to eq('ruby/gem') }

    context 'when template_base_folder provided' do
      let(:opts) { { template_base_folder: 'xmen' } }

      it { is_expected.to eq('xmen') }
    end
  end

  describe '.dom' do
    subject { director.dom }

    it { is_expected.to be_empty }

    describe '#github' do
      before { director.github(**opts, &block) }

      let(:opts) { { repo_name: 'test-repo' } }
      let(:block) { nil }

      it { is_expected.to include(github: include(repo_name: 'test-repo')) }
    end
  end

  context 'actions' do
    subject { director.builder.last_action }

    describe '#blueprint' do
      before { director.blueprint(**opts, &block) }

      describe '#add_file' do
        let(:block) { ->(_blueprint) { add_file('david.txt') } }

        it do
          is_expected.to include(
            action: :add_file,
            played: false,
            file: 'david.txt',
            opts: { on_exist: :skip, dom: {} }
          )
        end
      end

      describe '#add' do
        let(:block) { ->(_blueprint) { add('david.txt') } }

        it do
          is_expected.to include(
            action: :add_file,
            played: false,
            file: 'david.txt',
            opts: { on_exist: :skip, dom: {}, template_file: 'ruby/gem/david.txt' }
          )
        end
      end
    end
  end
end
