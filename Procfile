web: bundle exec puma -p $PORT -e $RAILS_ENV
worker: bundle exec sidekiq -t 25 -e $RAILS_ENV
