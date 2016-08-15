role :app, %w{araishikeiwai@46.101.91.181}
role :web, %w{araishikeiwai@46.101.91.181}
role :db, %w{araishikeiwai@46.101.91.181}

server '46.101.91.181', user: 'seeker', roles: %w{web}
