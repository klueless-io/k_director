# frozen_string_literal: true

RSpec.describe KDirector::Directors::Data do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:base_director_spec)) }

  let(:instance) { described_class.new(parent, name, **opts) }
  let(:name) { nil }
  let(:opts) { {} }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    context 'when configured with data' do
      subject { parent.builder.dom }

      before { instance }

      context 'when name is not provided' do
        let(:name) { nil }

        it { is_expected.to be_empty }

        context 'when key/value pairs are provided' do
          let(:opts) { { first_name: 'John', last_name: 'Doe' } }

          it { is_expected.to eq({ first_name: 'John', last_name: 'Doe' }) }
        end
      end

      context 'when name is provided' do
        let(:name) { :settings }

        it { is_expected.to eq(settings: {}) }

        context 'when key/value pairs are provided' do
          let(:opts) { { first_name: 'John', last_name: 'Doe' } }

          it { is_expected.to eq({ settings: { first_name: 'John', last_name: 'Doe' } }) }
        end
      end
    end
  end
end
