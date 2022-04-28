# frozen_string_literal: true

RSpec.describe KDirector::Dsls::BuilderOptionsDsl do
  let(:director) { described_class.init(k_builder, nil, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init }
  let(:opts) { {} }

  describe 'initialize' do
    describe '.k_builder' do
      subject { director }

      it { is_expected.to respond_to(:k_builder) }
    end
  end

  describe '.template_base_folder' do
    subject { director.template_base_folder }

    it { is_expected.to eq('ruby/components/builder_options') }
  end

  describe '.dom' do
    subject { director.dom }

    it { is_expected.to eq({ option_groups: [] }) }
  end

  # director = BuilderOptionsDirector.init
  # .add_group(:debug, params: %i[aaa xxx abc xyz], flags: %i[a1 b1 c1])
  # .add_group(:more, params: %i[abc xyz a1 a2 a3], flags: %i[the quick brown fox])

  describe '.add_group' do
    subject { director.dom }

    before { director.add_group(name, params: params, flags: flags) }

    let(:name) { :debug }
    let(:params) { %i[aaa xxx abc xyz] }
    let(:flags) { %i[a1 b1 c1] }
    let(:expected_dom) { { option_groups: [{ name: name, params: params, flags: flags }] } }

    it { is_expected.to eq(expected_dom) }

    context 'when writing builder_options.rb' do
      subject { director.builder.last_action }

      before { director.add('builder_options.rb') }
      it do
        is_expected.to include(
          action: :add_file,
          played: false,
          file: 'builder_options.rb',
          opts: include(dom: expected_dom)
        )
      end
    end
  end
end
