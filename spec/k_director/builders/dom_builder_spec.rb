# frozen_string_literal: true

RSpec.describe KDirector::Builders::DomBuilder do
  let(:instance) { described_class.new }

  describe 'initialize' do
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

    describe '#group_set' do
      context 'when key supplied' do
        before do
          instance.group_set(:github)
        end

        it { is_expected.to eq({ github: {} }) }

        context 'when key_pairs provided' do
          before { instance.group_set(:github, name: 'repo-name', organization: 'org-name') }

          it { is_expected.to eq({ github: { name: 'repo-name', organization: 'org-name' } }) }
        end
      end

      context 'when no key supplied' do
        before do
          instance.group_set(first_name: 'John', last_name: 'Doe')
        end

        it { is_expected.to eq({ first_name: 'John', last_name: 'Doe' }) }
      end
    end

    describe '#reset' do
      subject { instance }

      before do
        instance.set(:a, 1)
      end

      context 'before reset' do
        describe '.dom' do
          subject { instance.dom }

          it { is_expected.not_to be_empty }
        end
      end

      context 'after reset' do
        before { instance.reset }

        describe '.dom' do
          subject { instance.dom }

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
