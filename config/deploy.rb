require 'mina/rails'
require 'mina/git'
require 'mina/whenever'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# TODO uncomment for production ENDTODO require 'mina/rvm'    # for rvm support. (https://rvm.io)
require "yaml"

# Load environment variables from the application config
ENV.update YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'ticketfinders'
set :domain, ENV['DEPLOY_DOMAIN']
set :deploy_to, ENV['DEPLOY_TO']
set :repository, 'git@github.com:atasker/TFBASE.git'
set :branch, (ENV['DEPLOY_BRANCH'] || 'master')

set :user, ENV['DEPLOY_USER'] # Username in the server to SSH to.
set :forward_agent, true      # SSH forward_agent.
set :whenever_name, 'ticketfinders_production' # default: "#{domain}_#{rails_env}"
# probably you will need to add RSA key of repository server manually once before deploy
# just enter your server with `ssh user@server -A` and clone your repo to any folder

# Optional settings:
#   set :port, '30000'           # SSH port number.

# TODO uncomment for production ENDTODO set :rvm_use_path, '/usr/local/rvm/scripts/rvm'

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('public/uploads',
                                               'public/content')
set :shared_files, fetch(:shared_files, []).push('config/database.yml',
                                                 'config/application.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # TODO uncomment for production ENDTODO invoke :'rvm:use', 'ruby-2.0.0-p643'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
  comment "Don't forget to create shared/config/database.yml file"
  comment "Don't forget to create shared/config/application.yml file"
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    # TODO uncomment for production ENDTODO invoke :'whenever:update'

    on :launch do
      in_path "#{fetch(:current_path)}" do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
      # TODO uncomment for production ENDTODO invoke :'rvm:use', 'ruby-2.0.0-p643'
      # TODO uncomment for production ENDTODO invoke :'whenever:update'
      # TODO uncomment for production ENDTODO invoke :rake, 'sitemap:refresh:no_ping'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
