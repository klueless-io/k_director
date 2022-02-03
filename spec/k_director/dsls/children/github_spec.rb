# frozen_string_literal: true

KBuilder.configure(:github_spec) do |config|
  base_folder = File.expand_path("#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/")

  config.template_folders.add(:template, 'spec', '.templates') # Dir.pwd
  config.target_folders.add(:app, base_folder)
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

    context 'populate .dom with options' do
      subject { instance.builder.dom }

      context 'default options' do
        it do
          env_user = ENV['GH_USER'] || ENV['GITHUB_USER']

          is_expected.to include(
            github: include(
              repo_name: be_nil,
              user: env_user,
              organization: be_nil
            )
          )
        end
      end

      context 'custom options' do
        let(:opts) do
          {
            repo_name: 'name',
            user: 'user',
            organization: 'organization'
          }
        end

        it do
          is_expected.to include(
            github: include(
              repo_name: 'name',
              user: 'user',
              organization: 'organization'
            )
          )
        end
      end
    end

    context 'options are available via accessors' do
      let(:opts) do
        {
          repo_name: 'name',
          user: 'user',
          organization: 'organization'
        }
      end

      describe '#repo_name' do
        subject { instance.repo_name }

        it { is_expected.to eq('name') }
      end

      describe '#user' do
        subject { instance.user }

        it { is_expected.to eq('user') }
      end

      describe '#organization' do
        subject { instance.organization }

        it { is_expected.to eq('organization') }
      end
    end
  end

  describe '#scenarios' do
    subject { instance }

    let(:opts) { { repo_name: 'xmen' } }

    context 'list repositories' do
      xit { instance.list_repositories }
    end

    context 'create repository' do
      xit { instance.create_repository }
    end

    context 'open repository' do
      xit { instance.open_repository }
    end

    context 'delete repository' do
      xit { instance.delete_repository }
    end
  end
end
