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
  let(:env_user) { ENV['GH_USER'] || ENV['GITHUB_USER'] }

  describe 'initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    context 'populate .dom with options' do
      subject { instance.builder.dom }

      context 'default options' do
        fit do
          puts ENV
          puts '-' * 80
          puts env_user
          puts '-' * 80
          puts ENV['GH_USER']  
          puts '-' * 80
          puts JSON.pretty_generate(subject)
          puts '-' * 80
          is_expected.to include(
            github: include(
              repo_name: '',
              full_name: "#{env_user}/",
              link: "https://github.com/#{env_user}/",
              ssh_link: "git@github.com:#{env_user}/.git",
              username: env_user,
              organization: be_nil
            )
          )
        end
      end

      context 'custom options (username)' do
        let(:opts) do
          {
            repo_name: 'some_repo',
            username: 'username'
          }
        end

        it do
          is_expected.to include(
            github: include(
              repo_name: 'some_repo',
              full_name: 'username/some_repo',
              link: 'https://github.com/username/some_repo',
              ssh_link: 'git@github.com:username/some_repo.git',
              username: 'username',
              organization: be_nil
            )
          )
        end
      end

      context 'custom options (username and organization)' do
        let(:opts) do
          {
            repo_name: 'some_repo',
            username: 'username',
            organization: 'organization'
          }
        end

        it do
          is_expected.to include(
            github: include(
              repo_name: 'some_repo',
              full_name: 'organization/some_repo',
              link: 'https://github.com/organization/some_repo',
              ssh_link: 'git@github.com:organization/some_repo.git',
              username: 'username',
              organization: 'organization'
            )
          )
        end
      end
    end

    context 'options are available via accessors' do
      let(:opts) do
        {
          repo_name: 'some_repo',
          username: 'username',
          organization: 'organization'
        }
      end

      describe '#repo_name' do
        subject { instance.repo_name }

        it { is_expected.to eq('some_repo') }
      end

      describe '#username' do
        subject { instance.username }

        it { is_expected.to eq('username') }
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
