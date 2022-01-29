# frozen_string_literal: true

RSpec.describe KDirector::Builders::DomBuilder do
  describe 'initialize' do
    let(:instance) { described_class.new }

    subject { instance }

    it { is_expected.not_to be_nil }

    context '.dom' do
      subject { instance.dom }

      it { is_expected.to eq({}) }

      describe '#set' do
        before { instance.set(:a, 1) }

        it { is_expected.to eq({ a: 1 }) }

        describe '.last' do
          subject { instance.last }

          it { is_expected.to eq(key: :a, value: 1) }
        end

        describe '.last_key' do
          subject { instance.last_key }

          it { is_expected.to eq(:a) }
        end

        describe '.last_value' do
          subject { instance.last_value }

          it { is_expected.to eq(1) }
        end

        context 'when setup with array' do
          before { instance.set(:a, []) }

          it { is_expected.to eq({ a: [] }) }

          describe '#add' do
            before { instance.add(:a, 1) }

            it { is_expected.to eq({ a: [1] }) }

            describe '.last' do
              subject { instance.last }

              it { is_expected.to eq(key: :a, value: 1) }
            end

            context 'when add to existing key/array value' do
              before { instance.add(:a, 2) }

              it { is_expected.to eq({ a: [1, 2] }) }

              describe '.last' do
                subject { instance.last }

                it { is_expected.to eq(key: :a, value: 2) }
              end
            end
          end
        end
      end
    end
  end
end
