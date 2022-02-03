# frozen_string_literal: true

# klueless-io
# k_director
# kluless-sites

module KDirector
  module Dsls
    module Children
      # Github DSL provides useful GitHub actions such as (create, delete, list, open repository).
      class Github < KDirector::Directors::ChildDirector
        def initialize(parent, **opts)
          super(parent, **opts)

          defaults = {
            repo_name: opts[:repo_name], # || parent.builder.dom&[:github]&[:repo_name]
            username: opts[:username] || default_github_username, # || parent.builder.dom&[:github]&[:username]
            organization: opts[:organization] # || parent.builder.dom&[:github]&[:organization]
          }

          parent.builder.group_set(:github, **repo_info_hash(**defaults))
        end

        def repo_name
          parent.builder.dom.dig(:github, :repo_name)
        end

        def username
          parent.builder.dom.dig(:github, :username)
        end

        def organization
          parent.builder.dom.dig(:github, :organization)
        end

        def list_repositories
          repos = create_api.all_repositories

          KExt::Github::Printer.repositories_as_table repos

          log.kv 'Repository count', repos.length
        rescue StandardError => e
          log.exception(e)
        end

        def open_repository(**opts)
          info = repo_info(**opts)

          system("open -a 'Google Chrome' #{info.link}")
        end

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def create_repository(**opts)
          info = repo_info(**opts)

          if info.repo_name.blank?
            log.error 'Repository name is required'
            return
          end

          repo = create_api.all_repositories.find { |r| r.full_name == info.full_name }

          if repo.nil?
            log.heading 'Repository create'
            log.kv 'Repository Name', info.repo_name
            log.kv 'Repository Full Name', info.full_name
            log.kv 'Organization Name', info.organization if info.organization
            success = create_api.create_repository(info.repo_name, organization: info.organization)
            log.info "Repository: #{info.full_name} created" if success
            log.error "Repository: #{info.full_name} was not created" unless success

            system("open -a 'Google Chrome' #{info.link}") if opts[:open]
          else
            log.warn 'Repository already exists, nothing to create'
          end

          log_repo_info(info)
        rescue StandardError => e
          log.exception(e)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def delete_repository(**opts)
          info = repo_info(**opts)

          if info.repo_name.blank?
            log.error 'Repository name is required'
            return
          end

          repo = create_api.all_repositories.find { |r| r.full_name == info.full_name }

          if repo.present?
            log.heading 'Repository delete'
            log.kv 'Repository Name', info.repo_name
            log.kv 'Repository Full Name', info.full_name
            log.kv 'Organization Name', info.organization if info.organization
            success = delete_api.delete_repository(info.full_name, organization: info.organization)
            log.info "Repository: #{info.full_name} deleted" if success
            log.error "Repository: #{info.full_name} was not deleted" unless success
            # system("open -a 'Google Chrome' #{info.link}") if opts[:open]
          else
            log.warn 'Repository does not exist, nothing to delete'
          end

          log_repo_info(info)
        rescue StandardError => e
          log.exception(e)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def repo_info_hash(**opts)
          repo_name     = (opts[:repo_name] || self.repo_name).to_s
          username      = opts[:username] || self.username
          organization  = opts[:organization] || self.organization
          account       = organization || username
          full_name     = [account, repo_name].compact.join('/')
          link          = "https://github.com/#{full_name}"
          ssh_link      = "git@github.com:#{full_name}.git"

          {
            repo_name: repo_name,
            full_name: full_name,
            link: link,
            ssh_link: ssh_link,
            username: username,
            organization: organization
          }
        end

        def repo_info(**opts)
          OpenStruct.new(**repo_info_hash(**opts))
        end

        private

        def default_github_username
          KExt::Github.configuration.user
        end

        def create_api
          token = KExt::Github.configuration.personal_access_token
          KExt::Github::Api.instance(token)
        end

        def delete_api
          token = KExt::Github.configuration.personal_access_token_delete
          KExt::Github::Api.instance(token)
        end

        def log_repo_info(info)
          log.kv 'SSH', info.ssh_link
          log.kv 'HTTPS', info.git_link
          log.kv 'GITHUB', KUtil.console.hyperlink(info.link, info.link)

          # log.json repo.to_h
        end
      end
    end
  end
end
