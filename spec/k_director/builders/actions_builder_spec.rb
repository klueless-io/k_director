# frozen_string_literal: true

RSpec.describe KDirector::Builders::ActionsBuilder do
  let(:instance) { described_class.new }

  describe 'initialize' do
    subject { instance.dom }

    it { is_expected.to eq({}) }

    describe '.actions' do
      subject { instance.actions }

      it { is_expected.to be_empty }

      describe '#queue_action' do
        before { instance.queue_action({ a: 1, b: 2 }) }

        context '.actions' do
          subject { instance.actions }

          it do
            is_expected
              .to   have_attributes(length: 1)
              .and  include(a: 1, b: 2)
          end

          describe '#last_action' do
            subject { instance.last_action }

            it { is_expected.to eq({ a: 1, b: 2 }) }
          end

          context 'with two actions' do
            before { instance.queue_action({ c: 1, d: 2 }) }

            it do
              is_expected
                .to   have_attributes(length: 2)
                .and  include(a: 1, b: 2)
                .and  include(c: 1, d: 2)
            end

            describe '#last_action' do
              subject { instance.last_action }

              it { is_expected.to eq({ c: 1, d: 2 }) }
            end
          end
        end
      end
    end

    describe '#set' do
      context 'when key only' do
        subject { instance.set(:a) }

        it { expect { subject }.to raise_error(ArgumentError, 'set requires 2 or more arguments') }
      end

      context 'when simple key/value pair' do
        before { instance.set(:a, 1) }

        it { is_expected.to eq({ a: 1 }) }
      end

      describe 'with default value' do
        before { instance.set(:a, value, default_value: default_value) }

        let(:value) { 1 }
        let(:default_value) { 2 }

        context 'when value is set' do
          it { is_expected.to eq({ a: 1 }) }
        end

        context 'when value is not set' do
          let(:value) { nil }

          it { is_expected.to eq({ a: 2 }) }
        end

        context 'when value is false' do
          let(:value) { false }

          it { is_expected.to eq({ a: false }) }
        end
      end

      context 'when key_hierarchy provided' do
        before { instance.set(:a, :b, :c, 1) }

        it { is_expected.to eq({ a: { b: { c: 1 } } }) }
      end
    end

    describe '#add' do
      context 'when only key supplied' do
        subject { instance.add(:a) }

        it { expect { subject }.to raise_error(ArgumentError, 'add requires 2 or more arguments') }
      end

      context 'when simple key/value pair' do
        before { instance.add(:a, 1) }

        it { is_expected.to eq({ a: [1] }) }
      end

      describe 'with default value' do
        before { instance.add(:a, value, default_value: default_value) }

        let(:value) { 1 }
        let(:default_value) { 2 }

        context 'when value is add' do
          it { is_expected.to eq({ a: [1] }) }
        end

        context 'when value is not add' do
          let(:value) { nil }

          it { is_expected.to eq({ a: [2] }) }
        end

        context 'when value is false' do
          let(:value) { false }

          it { is_expected.to eq({ a: [false] }) }
        end
      end

      context 'when key_hierarchy provided' do
        before { instance.add(:a, :b, :c, 1) }

        it { is_expected.to eq({ a: { b: { c: [1] } } }) }
      end
    end

    describe '#reset' do
      subject { instance }

      before do
        instance.queue_action({ a: 1, b: 2 })
        instance.set(:a, 1)
      end

      context 'before reset' do
        describe '.actions' do
          subject { instance.actions }

          it { is_expected.not_to be_empty }
        end

        describe '.dom' do
          subject { instance.dom }

          it { is_expected.not_to be_empty }
        end
      end

      context 'after reset' do
        before { instance.reset }

        describe '.actions' do
          subject { instance.actions }

          it { is_expected.to be_empty }
        end

        describe '.dom' do
          subject { instance.dom }

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
