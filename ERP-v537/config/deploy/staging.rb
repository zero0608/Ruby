#for eternity modern
set :repo_url, 'git@github.com:hansonnb/nbenterprise.git'

set :deploy_to, '/var/www/sites/eternity-erp'

# set :rvm_type, :system
set :rvm_ruby_version, '2.6.0'
# set :rvm_path, '/usr/local/rvm/bin/rvm'


server '52.8.68.131',
  user: 'ubuntu',
  roles: %w{web app db},
  ssh_options: {
    user: 'box-admin', # overrides user setting above
    keys: %w(~/.ec2/eternity-erp-staging.pem),
    forward_agent: true,
    auth_methods: %w(publickey)
    # password: 'please use keys'
}


set :branch, 'dev-backup'
set :keep_releases, 3

set :rails_env, :staging