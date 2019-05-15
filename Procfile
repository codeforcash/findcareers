web: bundle exec puma -p $PORT -e $RAILS_ENV
# 2 since we only have 2 CPUs on Browserless
worker: bundle exec sidekiq -c 2 -t 25 -e $RAILS_ENV
