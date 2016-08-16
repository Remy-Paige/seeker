role :app, %w{seeker@46.101.91.181}
role :web, %w{seeker@46.101.91.181}
role :db, %w{seeker@46.101.91.181}

server '46.101.91.181', user: 'seeker', roles: %w{web}
