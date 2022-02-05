# frozen_string_literal: true

RSpec.describe KDirector::Dsls::Children::PackageJsonConfigurationExtension do
  let(:k_config) { KConfig }

  let(:cfg) { ->(config) {} }

  let(:instance) { k_config.configuration }

  before :each do
    k_config.configure(&cfg)
  end
  after :each do
    k_config.reset
  end

  context 'sample usage' do
    subject { instance.package_json.package_groups }
    let(:cfg) do
      lambda do |config|
        config.package_json.set_package_group('custom', 'Custom List of Packages', %w[package1 package2 package3])
      end
    end

    context ".package_group['custom']" do
      subject { instance.package_json.package_groups['custom'] }

      it do
        is_expected
          .to have_attributes(key: 'custom',
                              description: 'Custom List of Packages',
                              package_names: %w[package1 package2 package3])
      end
    end
  end
end
