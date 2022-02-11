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
