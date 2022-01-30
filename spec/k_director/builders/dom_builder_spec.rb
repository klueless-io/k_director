# frozen_string_literal: true

RSpec.describe KDirector::Builders::DomBuilder do
  describe 'initialize' do
    let(:instance) { described_class.new }

    subject { instance.dom }

    it { is_expected.to eq({}) }

    describe '#set' do
      context 'when key only' do
        subject { instance.set(:a) }

        it { expect { subject }.to raise_error(ArgumentError, 'set requires 2 or more arguments') }
      end

      context 'when simple key/value pair' do
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
      end

      describe 'with default value' do
        before { instance.set(:a, value, default_value: default_value) }

        subject { instance.last_value }

        let(:value) { 1 }
        let(:default_value) { 2 }

        context 'when value is set' do
          it { is_expected.to eq(1) }
        end

        context 'when value is not set' do
          let(:value) { nil }

          it { is_expected.to eq(2) }
        end

        context 'when value is false' do
          let(:value) { false }

          it { is_expected.to eq(false) }
        end
      end

      context 'when key_hierarchy provided' do
        before { instance.set(:a, :b, :c, 1) }

        it { is_expected.to eq({ a: { b: { c: 1 } } }) }

        describe '.last' do
          subject { instance.last }

          it { is_expected.to eq(key: :c, value: 1) }
        end

        describe '.last_key' do
          subject { instance.last_key }

          it { is_expected.to eq(:c) }
        end

        describe '.last_value' do
          subject { instance.last_value }

          it { is_expected.to eq(1) }
        end
      end
    end

    describe '#add' do
      context 'when only key supplied' do
        subject { instance.add(:a) }

        it { expect { subject }.to raise_error(ArgumentError, 'add requires 2 or more arguments') }
      end

      context 'when simple key/value pair' do
        before {instance.add(:a, 1) }

        it { is_expected.to eq({ a: [1] }) }

        describe '.last' do
          subject { instance.last }

          it { is_expected.to eq(key: :a, value: [1]) }
        end

        describe '.last_key' do
          subject { instance.last_key }

          it { is_expected.to eq(:a) }
        end

        describe '.last_value' do
          subject { instance.last_value }

          it { is_expected.to eq([1]) }
        end
      end

      describe 'with default value' do
        before { instance.add(:a, value, default_value: default_value) }

        subject { instance.last_value }

        let(:value) { 1 }
        let(:default_value) { 2 }

        context 'when value is add' do
          it { is_expected.to eq([1]) }
        end

        context 'when value is not add' do
          let(:value) { nil }

          it { is_expected.to eq([2]) }
        end

        context 'when value is false' do
          let(:value) { false }

          it { is_expected.to eq([false]) }
        end
      end

      context 'when key_hierarchy provided' do
        before { instance.add(:a, :b, :c, 1) }

        it { is_expected.to eq({ a: { b: { c: [1] } } }) }

        describe '.last' do
          subject { instance.last }

          it { is_expected.to eq(key: :c, value: [1]) }
        end

        describe '.last_key' do
          subject { instance.last_key }

          it { is_expected.to eq(:c) }
        end

        describe '.last_value' do
          subject { instance.last_value }

          it { is_expected.to eq([1]) }
        end
      end
    end
  end
end
