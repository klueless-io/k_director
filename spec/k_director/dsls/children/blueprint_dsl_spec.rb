# frozen_string_literal: true

KBuilder.configure(:blueprint_dsl_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
end

Handlebars::Helpers.configure do |config|
  config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_helpers.json')
  config.helper_config_file = config_file

  string_config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_string_formatters.json')
  config.string_formatter_config_file = string_config_file
end

RSpec.describe KDirector::Dsls::Children::Blueprint do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder, **parent_opts) }
  let(:parent_opts) { {} }

  let(:instance) { described_class.new(parent, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KBuilder.configuration(:blueprint_dsl_spec)) }
  let(:opts) { {} }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }
  end

  describe '#add' do
    before { instance.add(output_file, **opts) }

    subject { instance.builder.last_node }

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

    context 'when parent_opts[:template_base_folder] is set' do
      let(:parent_opts) { { template_base_folder: 'xmen' } }

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
          let(:parent_opts) { { template_base_folder: 'xmen' } }

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

  context 'when using quick overrides' do
    subject { instance.builder.last_node[:opts] }

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

  describe '#run_template_script' do
    before { instance.run_template_script(template_file, **opts) }

    subject { instance.builder.last_node }

    let(:template_file) { 'somescript.sh' }
    let(:opts) { {} }

    it 'should have run_template_script action' do
      is_expected.to include(
        action: :run_script,
        played: false,
        script: 'template not found: somescript.sh'
      )
    end

    context 'when parent_opts[:template_base_folder] is set' do
      let(:parent_opts) { { template_base_folder: 'xmen' } }

      it 'should have run_template_script action' do
        is_expected.to include(
          action: :run_script,
          played: false,
          script: 'template not found: xmen/somescript.sh'
        )
      end
    end

    context 'when template_subfolder is set' do
      let(:opts) { { template_subfolder: 'subfolder' } }

      it 'should have run_template_script action' do
        is_expected.to include(
          action: :run_script,
          played: false,
          script: 'template not found: subfolder/somescript.sh'
        )
      end
    end

    context 'when template_base_folder, template_subfolder and template_file is set' do
      let(:parent_opts) { { template_base_folder: 'xmen' } }
      let(:opts) { { template_subfolder: 'subfolder' } }

      it 'should have run_template_script action' do
        is_expected.to include(
          action: :run_script,
          played: false,
          script: 'template not found: xmen/subfolder/somescript.sh'
        )
      end
    end
  end
end
