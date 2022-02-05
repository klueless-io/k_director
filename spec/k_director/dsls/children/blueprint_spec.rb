# frozen_string_literal: true

KConfig.configure(:blueprint_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
  config.target_folders.add(:xmen, base_folder, 'xmen')
end

RSpec.describe KDirector::Dsls::Children::Blueprint do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder, **parent_opts) }
  let(:parent_opts) { {} }

  let(:instance) { described_class.new(parent, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:blueprint_spec)) }
  let(:opts) { {} }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }
  end

  describe '#add' do
    before { instance.add(output_file, **opts) }

    subject { instance.builder.last_action }

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

  describe '#run_template_script' do
    before { instance.run_template_script(template_file, **opts) }

    subject { instance.builder.last_action }

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

  context 'SCENARIOS' do
    before do
      instance.set_current_folder_action(:app)

      # touch a file
      instance.add('sample.txt')

      # create file using template_file
      instance.add('sample-2.txt',
                   template_file: 'sample.txt',
                   name: 'sample-2')

      # create file in different folder using template_file
      instance.add('sample-3.txt',
                   template_file: 'sample.txt',
                   name: 'xman',
                   folder_key: :xmen)

      # open the output_file
      instance.oadd('sample-2.txt')

      # open the template_file
      instance.tadd('sample-2.txt')

      # force write the output_file
      instance.fadd('sample-2.txt')
    end

    # it '#scenario_1' do
    #   config = KConfig.configuration(:base_director_spec)
    #   config.debug
    #   instance.debug
    #   instance.builder.debug
    #   config.target_folders.debug
    #   # instance.play_actions
    #   # instance.k_builder.run_script("code .")
    #   # sleep 3
    # end
  end
end
