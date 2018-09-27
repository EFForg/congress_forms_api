#!/bin/sh

# Run migrations, if desired
if [ "$DB_MIGRATE" = "true" ]; then
  bundle exec rake db:migrate
fi

exec "$@"
