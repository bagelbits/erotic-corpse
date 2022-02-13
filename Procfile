web: RUN_TYPE=web bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: RUN_TYPE=worker bundle exec sidekiq -C config/sidekiq.yml -e $RAILS_ENV
