# frozen_string_literal: true

RSpec.describe KDirector::Builders::DomBuilder do
  describe 'initialize' do
    let(:instance) { described_class.new(dom) }
    let(:dom) { nil }

    subject { instance }

    it { is_expected.not_to be_nil }

    context '.dom' do
      subject { instance.dom }

      it { is_expected.to eq({}) }

      context 'when custom dom provided' do
        let(:dom) { { david: :cruwys } }

        it { is_expected.to eq(dom) }

        describe '.data' do
          subject { instance.data }

          it { is_expected.to have_attributes(david: :cruwys) }
        end
      end
    end

    context '.last_node' do
      subject { instance.last_node }

      it { is_expected.to be_nil }
    end
  end
end
