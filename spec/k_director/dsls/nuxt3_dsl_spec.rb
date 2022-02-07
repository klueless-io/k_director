# frozen_string_literal: true

KConfig.configure(:nuxt3_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.target_folders.add(:app, base_folder)
end

RSpec.describe KDirector::Dsls::Nuxt3Dsl do
  let(:director) { described_class.init(k_builder, nil, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:nuxt3_spec)) }
  let(:opts) { {} }

  describe 'initialize' do
    describe '.k_builder' do
      subject { director.k_builder }

      it { is_expected.to eq(k_builder) }
    end
  end

  describe '.template_base_folder' do
    subject { director.template_base_folder }

    it { is_expected.to eq('nuxt3') }

    context 'when template_base_folder provided' do
      let(:opts) { { template_base_folder: 'xmen' } }

      it { is_expected.to eq('xmen') }
    end
  end
end
