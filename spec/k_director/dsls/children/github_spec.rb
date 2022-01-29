# frozen_string_literal: true

KBuilder.configure(:github_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
end

Handlebars::Helpers.configure do |config|
  config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_helpers.json')
  config.helper_config_file = config_file

  string_config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_string_formatters.json')
  config.string_formatter_config_file = string_config_file
end

RSpec.describe KDirector::Dsls::Children::Github do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder, **parent_opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KBuilder.configuration(:github_spec)) }
  let(:parent_opts) { {} }

  let(:instance) { described_class.new(parent, **opts) }
  let(:opts) { {} }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }
  end

  context 'setup parent director' do
    subject { parent }

    it { is_expected.to be_a(KDirector::Directors::BaseDirector) }

    context 'when not configured' do
      context '.options.repo_name' do
        subject { instance.options.repo_name }
      
        it { is_expected.to be_nil }
      end

      context '.options.repo_organization' do
        subject { instance.options.repo_organization }
      
        it { is_expected.to be_nil }
      end
    end
  end

end
