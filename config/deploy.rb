set :application, 'note'
set :repo_url, 'git@github.com:cwheart/note.git'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/unicorn.rb config/puma.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

namespace :deploy do

  desc "Start application"
  task :start do
    on roles(:app) do
      execute "cd #{deploy_to}/current/ && RAILS_ENV=#{fetch(:rails_env)} bundle exec unicorn_rails -c #{deploy_to}/current/config/unicorn.rb -D"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
       execute "kill -USR2 `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
    end
  end

  desc "Stop application"
  task :stop do
    on roles(:app) do
      execute "kill -QUIT `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
