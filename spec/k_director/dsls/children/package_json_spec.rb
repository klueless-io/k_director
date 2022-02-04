# frozen_string_literal: true

KBuilder.configure(:package_json_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
end

RSpec.describe KDirector::Dsls::Children::PackageJson do
  let(:parent) { KDirector::Directors::BaseDirector.init(k_builder, **parent_opts) }
  let(:k_builder) { KBuilder::BaseBuilder.init(KBuilder.configuration(:package_json_spec)) }
  let(:parent_opts) { {} }

  let(:instance) { described_class.new(parent, **opts) }
  let(:opts) { {} }
end
