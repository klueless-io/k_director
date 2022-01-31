# frozen_string_literal: true

RSpec.describe KDirector::Directors::Data do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KBuilder.configuration(:base_director_spec)) }

  let(:instance) { described_class.new(parent, name, **opts) }
  let(:name) { nil }
  let(:opts) { {} }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    context 'when configured with data' do
      subject { parent.builder.dom }

      context 'when name is not provided' do
        let(:name) { nil }

        it { is_expected.to be_empty }
      end

      context 'when name is provided' do
        let(:name) { :settings }

        it { is_expected.to eq(settings: {}) }
      end
    end
  end
end
