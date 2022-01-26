# frozen_string_literal: true

module Dsl
  class Github < Dsl::Directors::ChildDirector
    def initialize(parent, **opts)
      super(parent, **opts)

      @options.repo_name          ||= parent.options.repo_name
      @options.repo_organization  ||= parent.options.repo_organization
    end

    def repo_name
      @options.repo_name
    end

    def repo_organization
      @options.repo_organization
    end

    def list_repositories
      repos = api.all_repositories

      KExt::Github::Printer::repositories_as_table repos

      log.kv 'Repository count', repos.length
    rescue StandardError => error
      log.exception(error)
    end

    def open_repository(**opts)
      info = repo_info(**opts)

      system("open -a 'Google Chrome' #{info.link}")
    end

    def create_repository(**opts)
      info = repo_info(**opts)

      repo = api.all_repositories.find { |r| r.full_name == info.full_name }

      if repo.nil?
        log.heading 'Repository create'
        log.kv 'Repository Name', info.name
        log.kv 'Repository Full Name', info.full_name
        log.kv 'Organization Name', info.organization if info.organization
        success = api.create_repository(info.name, organization: info.organization)
        log.info "Repository: #{info.full_name} created" if success
        log.error "Repository: #{info.full_name} was not created" unless success

        system("open -a 'Google Chrome' #{info.link}") if opts[:open]
      else
        log.warn 'Repository already exists, nothing to create'
      end

      log_repo_info(info)
    rescue StandardError => error
      log.exception(error)
    end

    def delete_repository(**opts)
      info = repo_info(**opts)

      repo = api.all_repositories.find { |r| r.full_name == info.full_name }

      if repo.present?
        log.heading 'Repository delete'
        log.kv 'Repository Name', info.name
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
    rescue StandardError => error
      log.exception(error)
    end
    
    def repo_info(**opts)
      name          = opts[:name] || self.repo_name
      name          = name.to_s
      username      = opts[:username] || self.username
      organization  = opts[:organization] || self.repo_organization
      account       = organization || username
      full_name     = [account, name].compact.join("/")
      link          = "https://github.com/#{full_name}"
      ssh_link      = "git@github.com:#{full_name}.git"

      OpenStruct.new(
        name: name,
        full_name: full_name,
        link: link,
        ssh_link: ssh_link,
        username: username,
        organization: organization
      )
    end

    private


    def username
      KExt::Github.configuration.user
    end

    def api
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
