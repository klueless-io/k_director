# frozen_string_literal: true

RSpec.describe KDirector::Dsls::BasicDsl do
  let(:director) { described_class.init(k_builder, nil, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init }
  let(:opts) { {} }

  describe 'initialize' do
    describe '.k_builder' do
      subject { director.k_builder }

      it { is_expected.to eq(k_builder) }
    end
  end

  describe '.template_base_folder' do
    subject { director.template_base_folder }

    it { is_expected.to eq('basic') }

    context 'when template_base_folder provided' do
      let(:opts) { { template_base_folder: 'xmen' } }

      it { is_expected.to eq('xmen') }
    end
  end
end
