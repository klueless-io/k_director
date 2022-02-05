# frozen_string_literal: true

KConfig.configure(:base_director_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
end

RSpec.describe KDirector::Directors::ChildDirector do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder, **parent_opts) }
  let(:parent_opts) { {} }

  let(:instance) { described_class.new(parent, **opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KConfig.configuration(:base_director_spec)) }
  let(:opts) { {} }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }
    it { is_expected.to be_a(KDirector::Directors::ChildDirector) }

    context '.parent' do
      subject { instance.parent }

      it { is_expected.to be_a(KDirector::Directors::BaseDirector) }
    end
  end
end
