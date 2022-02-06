# frozen_string_literal: true

# KConfig.configure(:package_json_spec) do |config|
#   base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

#   config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
#   config.target_folders.add(:app, base_folder)
# end

RSpec.describe KDirector::Dsls::Children::PackageJson do
  let(:k_config) { KConfig }

  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder, **parent_opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init }
  let(:parent_opts) { {} }

  let(:director) { described_class.new(parent, **opts) }
  let(:opts) { {} }

  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:target_folder) { samples_folder }
  # let(:app_template_folder) { File.join(samples_folder, 'app-template') }
  # let(:global_template_folder) { File.join(samples_folder, 'global-template') }

  # yallist and boolbase are being used due to the low dependency packages
  let(:yallist) { 'yallist' }
  let(:node_target_yallist) { File.join(k_builder.target_folder, 'node_modules', 'yallist') }
  let(:boolbase) { 'boolbase' }
  let(:node_target_boolbase) { File.join(k_builder.target_folder, 'node_modules', 'boolbase') }
  let(:multiple_packages) { [yallist, boolbase] }

  before(:each) { k_config.configure(&cfg) }
  after(:each) { k_config.reset }

  shared_context 'setup_temp_dir' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }
  end

  shared_context 'basic configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:package, target_folder)

        # Default opinionated package groups
        config.package_json.set_default_package_groups

        # Custom package group
        config.package_json.set_package_group('xmen', 'Sample Packages', multiple_packages)

        # config.template_folders.add(:global , global_template_folder)
        # config.template_folders.add(:app , app_template_folder)
      }
    end
  end

  describe '#initialize' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    describe '.package_file' do
      subject { director.package_file }
      it { is_expected.not_to be_empty }
      it { is_expected.to eq(File.join(k_builder.target_folder, 'package.json')) }
    end

    context '.dependency_type' do
      subject { director.dependency_type }
      it { is_expected.to eq(:development) }
    end

    describe '.package' do
      subject { director.package }

      it { expect(-> { subject }).to raise_error KDirector::Error, 'package.json does not exist' }
    end
  end

  context 'set context for production/development' do
    include_context 'basic configuration'

    context 'when production' do
      before { director.production }

      context '.dependency_type' do
        subject { director.dependency_type }
        it { is_expected.to eq(:production) }
      end
      context '.dependency_option' do
        subject { director.dependency_option }
        it { is_expected.to eq('-P') }
      end
    end

    context 'when development' do
      before { director.development }

      context '.dependency_type' do
        subject { director.dependency_type }
        it { is_expected.to eq(:development) }
      end
      context '.dependency_option' do
        subject { director.dependency_option }
        it { is_expected.to eq('-D') }
      end
    end
  end

  describe '#parse_options' do
    include_context 'basic configuration'

    subject { director.parse_options(options).join(' ') }

    let(:options) { nil }

    context 'when nil' do
      it { is_expected.to be_empty }
    end

    context 'when empty string' do
      let(:options) { '' }
      it { is_expected.to be_empty }
    end

    context 'when multiple options' do
      let(:options) { '-a -B --c' }
      it { is_expected.to eq('-a -B --c') }
    end

    context 'when multiple options wit extra spacing' do
      let(:options) { '-abc     -xyz' }
      it { is_expected.to eq('-abc -xyz') }
    end

    context 'with required_options' do
      subject { director.parse_options(options, required_options).join(' ') }

      let(:options) { '-a     -b' }
      let(:required_options) { nil }

      context 'when nil' do
        it { is_expected.to eq('-a -b') }
      end

      context 'when empty string' do
        let(:required_options) { '' }
        it { is_expected.to eq('-a -b') }
      end

      context 'when add required option' do
        let(:required_options) { '-req-option' }
        it { is_expected.to eq('-a -b -req-option') }
      end

      context 'when add existing and required options' do
        let(:required_options) { '-req1   -b  -req2 -a' }
        it { is_expected.to eq('-a -b -req1 -req2') }
      end
    end
  end

  describe '#npm_init' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    before :each do
      director.npm_init
    end

    describe '#package_file' do
      subject { director.package_file }

      it { is_expected.to eq(File.join(target_folder, 'package.json')) }
    end

    describe '#package' do
      subject { director.package }

      it { is_expected.to include('name' => start_with('rspec-')) }
    end

    context 'set custom package property' do
      subject { director.set('description', 'some description').package }

      it { is_expected.to include('description' => 'some description') }
    end

    context 'working with scripts' do
      subject { director.package['scripts'] }

      context 'has default script' do
        it { is_expected.to have_key('test') }
      end

      context 'remove script' do
        subject { director.remove_script('test').package['scripts'] }

        it { is_expected.not_to have_key('test') }
      end

      context 'add script' do
        subject { director.add_script('custom', 'do something').package['scripts'] }

        it do
          is_expected
            .to  have_key('custom')
            .and include('custom' => a_value)
        end
      end
    end
  end

  describe '#npm_install' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    context 'when options are configured via builder' do
      subject { director.package }

      before :each do
        director.npm_init
                .production
                .npm_install(boolbase)
                .development
                .npm_install(yallist)
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_truthy
        expect(Dir.exist?(node_target_boolbase)).to be_truthy

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value })
          .and have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'when two packages are supplied manually' do
      subject { director.package }
      before :each do
        director.npm_init
                .npm_install(multiple_packages, options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_truthy
          expect(Dir.exist?(node_target_boolbase)).to be_truthy

          is_expected
            .to  have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end

    context 'when options are supplied manually' do
      subject { director.package }

      before :each do
        director.npm_init
                .npm_install(yallist, options: options)
      end

      context 'install dependency' do
        context 'development' do
          let(:options) { '-D' }

          it do
            expect(Dir.exist?(node_target_yallist)).to be_truthy

            is_expected.to have_key('devDependencies')
              .and include('devDependencies' => { 'yallist' => a_value })
          end
        end

        context 'production' do
          let(:options) { '-P' }

          it do
            expect(Dir.exist?(node_target_yallist)).to be_truthy

            is_expected.to have_key('dependencies')
              .and include('dependencies' => { 'yallist' => a_value })
          end
        end
      end
    end
  end

  describe '#npm_add' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    # adds dependency, but does not install
    subject { director.package }

    context 'when options are configured via builder' do
      before :each do
        director.npm_init
                .production
                .npm_add(boolbase)
                .development
                .npm_add(yallist)
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_falsey
        expect(Dir.exist?(node_target_boolbase)).to be_falsey

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value })
          .and have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        director.npm_init
                .npm_add(yallist, options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected.to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value })
        end
      end

      context 'production' do
        let(:options) { '-P' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected.to have_key('dependencies')
            .and include('dependencies' => { 'yallist' => a_value })
        end
      end
    end
  end

  describe '#npm_add_group' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    # adds dependency, but does not install
    subject { director.package }

    context 'when options are configured via builder' do
      before :each do
        director.npm_init
                .production
                .npm_add_group('xmen')
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_falsey
        expect(Dir.exist?(node_target_boolbase)).to be_falsey

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value, 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        director.npm_init
                .npm_add_group('xmen', options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected
            .to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end
  end

  describe '#npm_install_group' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    subject { director.package }

    context 'when options are configured via builder' do
      before :each do
        director.npm_init
                .production
                .npm_install_group('xmen')
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_truthy
        expect(Dir.exist?(node_target_boolbase)).to be_truthy

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value, 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        director.npm_init
                .npm_install_group('xmen', options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_truthy
          expect(Dir.exist?(node_target_yallist)).to be_truthy

          is_expected
            .to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end
  end

  describe '#set' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    subject { director.package }

    context 'when options are configured via builder' do
      before(:each) { director.npm_init.set('name', 'xmen') }

      it { is_expected.to have_key('name').and include('name' => 'xmen') }
    end

    context 'when key is not trimmed' do
      before(:each) { director.npm_init.set(' name ', 'xmen') }

      it { is_expected.to have_key('name').and include('name' => 'xmen') }
    end

    context 'when key is a symbol' do
      before(:each) { director.npm_init.set(:name, 'xmen') }

      it { is_expected.to have_key('name').and include('name' => 'xmen') }
    end

    context 'when group option provided' do
      subject { director.package['scripts'] }

      before(:each) do
        director
          .npm_init
          .set('build', 'build something', group: 'scripts')
          .set('run', 'run something', group: 'scripts')
      end
      it { is_expected.to include('build' => 'build something').and include('run' => 'run something') }
    end
  end

  describe '#remove' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    subject { director.package }

    context 'when options are configured via builder' do
      before(:each) do
        director
          .npm_init
          .set('name', 'xmen')
          .remove('name')
      end

      it { is_expected.not_to have_key('name') }
    end

    context 'when key is not trimmed' do
      before(:each) do
        director
          .npm_init
          .set('name', 'xmen')
          .remove('name')
      end

      it { is_expected.not_to have_key('name') }
    end

    context 'when key is a symbol' do
      before(:each) do
        director
          .npm_init
          .set('name', 'xmen')
          .remove(:name)
      end

      it { is_expected.not_to have_key('name') }
    end

    context 'when group option provided' do
      subject { director.package['scripts'] }

      before(:each) do
        director
          .npm_init
          .set('build', 'build something', group: 'scripts')
          .remove('build', group: 'scripts')
      end

      it { is_expected.not_to include('build') }
    end
  end

  describe '#sort' do
    include_context 'setup_temp_dir'
    include_context 'basic configuration'

    subject { director.package.keys }

    context 'when options are configured via builder' do
      before :each do
        director.npm_init
                .development
                .npm_add(yallist)
                .production
                .npm_add(boolbase)
                .sort
      end

      it { is_expected.to eq(%w[name version description keywords license author main scripts dependencies devDependencies]) }
    end
  end
end
