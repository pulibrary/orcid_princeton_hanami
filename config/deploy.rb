# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.20.0'

set :application, 'orcid_princeton'
set :repo_url, 'https://github.com/pulibrary/orcid_princeton_hanami.git'

set :linked_dirs, %w[log public/assets node_modules]

# Default branch is :main
set :branch, ENV['BRANCH'] || 'main'

set :deploy_to, '/opt/orcid_princeton'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# you can run on s single host with `cap --hosts=orcid-staging1.princeton.edu staging`

namespace :hanami do
  desc 'Marks the server(s) to be added back to the loadbalancer'
  task :asset_compile do
    on roles(:app) do
      within release_path do
        execute 'yarn', 'install'
        execute 'bundle', 'exec hanami assets compile'
      end
    end
  end

  desc 'Update the administrators to match the current settings'
  task :create_admin_users do
    on roles(:app) do
      within release_path do
        execute 'bundle', 'exec rake users:create_admin_users'
      end
    end
  end
end

before 'deploy:publishing', 'hanami:asset_compile'
before 'deploy:publishing', 'hanami:create_admin_users'
