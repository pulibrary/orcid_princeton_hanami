# frozen_string_literal: true

namespace :servers do
  task initialize: :environment do
    system('hanami db create')
    system('hanami db migrate')
    system('hanami db seed')
  end

  desc 'Starts development dependencies'
  task start: :environment do
    # should start automatically for server start
    system('rake servers:initialize')
    system('rake servers:initialize HANAMI_ENV=test')
  end

  desc 'Stop development dependencies'
  task :stop do
    system 'lando stop'
  end
end
