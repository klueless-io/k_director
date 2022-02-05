# frozen_string_literal: true

RSpec.describe KDirector::Dsls::Nuxt3Dsl do
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

    it { is_expected.to eq('nuxt3') }

    context 'when template_base_folder provided' do
      let(:opts) { { template_base_folder: 'xmen' } }

      it { is_expected.to eq('xmen') }
    end
  end

  context 'child directors' do
    subject { director }

    describe '#github' do
      it { is_expected.to respond_to(:github) }
    end

    describe '#package_json' do
      it { is_expected.to respond_to(:package_json) }
    end

    describe '#blueprint' do
      it { is_expected.to respond_to(:blueprint) }
    end
  end
end
