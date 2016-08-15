# config valid only for current version of Capistrano
lock '3.6.0'
set :application, 'seeker'
set :repo_url, 'git@github.com:araishikeiwai/seeker.git'
set :deploy_to, '/home/seeker'
set :format, :pretty
set :pty, true
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/storage')
set :passenger_restart_with_touch, true
