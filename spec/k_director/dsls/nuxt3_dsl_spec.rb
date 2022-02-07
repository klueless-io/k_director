# frozen_string_literal: true

class Nuxt3InsideBlock
  class << self
    attr_reader :name
  end

  class << self
    attr_writer :name
  end
end

KConfig.configure(:nuxt3_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.target_folders.add(:app, base_folder)
end

RSpec.describe KDirector::Dsls::Nuxt3Dsl do
  let(:director) { described_class.init(k_builder, nil, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:nuxt3_spec)) }
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

      context 'when block given' do
        subject { Nuxt3InsideBlock.name }

        before do
          Nuxt3InsideBlock.name = nil
          director.github { |_| Nuxt3InsideBlock.name = 'github' }
        end

        it { is_expected.to eq('github') }

        context 'when option active is false' do
          let(:opts) { { active: false } }

          it { is_expected.to eq(nil) }
        end
      end
    end

    describe '#package_json' do
      it { is_expected.to respond_to(:package_json) }

      context 'when block given' do
        subject { Nuxt3InsideBlock.name }

        before do
          Nuxt3InsideBlock.name = nil
          director.package_json { |_| Nuxt3InsideBlock.name = 'package_json' }
        end

        it { is_expected.to eq('package_json') }

        # context 'when option active is false' do
        #   let(:opts) { { active: false } }

        #   it { is_expected.to eq(nil) }
        # end
      end
    end

    describe '#blueprint' do
      it { is_expected.to respond_to(:blueprint) }

      context 'when block given' do
        subject { Nuxt3InsideBlock.name }

        before do
          Nuxt3InsideBlock.name = nil
          director.blueprint { |_| Nuxt3InsideBlock.name = 'blueprint' }
        end

        it { is_expected.to eq('blueprint') }

        context 'when option active is false' do
          let(:opts) { { active: false } }

          it { is_expected.to eq(nil) }
        end
      end
    end
  end
end
