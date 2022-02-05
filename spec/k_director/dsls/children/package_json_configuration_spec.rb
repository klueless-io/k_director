# frozen_string_literal: true

RSpec.describe KDirector::Dsls::Children::PackageJsonConfiguration do
  let(:instance) { described_class.new }

  describe '#set_default_package_groups' do
    before do
      instance.set_default_package_groups
    end

    subject { instance.package_groups }

    it do
      is_expected
        .to  have_key('webpack')
        .and have_key('swc')
        .and have_key('babel')
        .and have_key('typescript')
    end

    context ".package_group['webpack']" do
      subject { instance.package_groups['webpack'] }

      it do
        is_expected
          .to have_attributes(key: 'webpack',
                              description: 'Webpack V5',
                              package_names: %w[webpack webpack-cli webpack-dev-server])
      end
    end
  end

  describe '#set_package_group' do
    before do
      instance.set_package_group('custom', 'Custom List of Packages', %w[package1 package2 package3])
    end

    subject { instance.package_groups['custom'] }

    it do
      is_expected
        .to have_attributes(key: 'custom',
                            description: 'Custom List of Packages',
                            package_names: %w[package1 package2 package3])
    end
  end
end
