set :application, 'specscan'
set :repository, 'git@github.com:sibprogrammer/specscan.git'
set :scm, :git
set :deploy_via, :remote_cache
set :deploy_to, '/var/www/panel'
set :user, 'deployer'

set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ree-1.8.7-2012.02/bin:/usr/local/rvm/gems/ree-1.8.7-2012.02@global/bin:/usr/local/rvm/rubies/ree-1.8.7-2012.02/bin:/usr/local/rvm/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.8.7',
  'GEM_HOME' => '/usr/local/rvm/gems/ree-1.8.7-2012.02',
  'GEM_PATH' => '/usr/local/rvm/gems/ree-1.8.7-2012.02:/usr/local/rvm/gems/ree-1.8.7-2012.02@global',
  'BUNDLE_PATH' => '/usr/local/rvm/gems/ree-1.8.7-2012.02@global'
}

role :web, 'hs.specscan.ru'
role :app, 'hs.specscan.ru'
role :db, 'hs.specscan.ru', :primary => true

after 'deploy:update_code', 'deploy:symlink_files'
after 'deploy:update_code', 'deploy:precompile'
after 'deploy:update_code', 'deploy:fix_permissions'
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Symlink files"
  task :symlink_files, :roles => :app do
    %w{ config/database.yml config/config.yml config/daemons.yml config/retranslators.yml db/production.sqlite3 }.each do |file|
      run "ln -nfs #{deploy_to}/shared/#{file} #{release_path}/#{file}"
    end
  end

  task :precompile, :role => :app do
    run "cd #{release_path}/ && rake assets:precompile"
  end

  task :fix_permissions, :role => :app do
    %w{ config.ru config/environment.rb log tmp }.each do |file|
      run "sudo chown -R www-data:www-data #{release_path}/#{file}"
    end
  end
end

