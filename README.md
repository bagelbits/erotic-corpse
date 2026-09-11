# Erotic Corpse

![Build Status](https://github.com/bagelbits/erotic-corpse/workflows/Erotic%20Corpse%20CI/badge.svg?branch=main)

This is online take on Exquisite Corpse. However, instead of drawing, you continue the story with the only the last sentence as the prompt.

## Development

### Requirements

| | Version | Pinned in |
|---|---|---|
| Ruby | 3.4.10 | `.ruby-version` |
| Node | 22.14.0 | `.nvmrc` |
| MySQL | 8.0 | matches CI |
| Redis | any | jobs are enqueued when a ticket is taken and when a prompt is submitted |

On macOS the `mysql2` native extension needs the MySQL client headers, which are not installed with Ruby:

```sh
brew install mysql-client
bundle config set --global build.mysql2 \
  --with-mysql-config=/opt/homebrew/opt/mysql-client/bin/mysql_config
```

### Setup

```sh
bundle install
npm ci
bin/rails db:create       # creates both the development and test databases
bin/rails db:schema:load
```

Run `db:create` **without** `RUN_TYPE` set. The app runs pending migrations from an `after_initialize` hook whenever `RUN_TYPE=web` (see `config/application.rb`), which means booting that way requires the database to exist already.

### Running

```sh
bin/shakapacker-watch --watch              # rebuild packs on save
RUN_TYPE=web bin/rails server              # http://localhost:3000
bundle exec sidekiq -C config/sidekiq.yml  # background jobs
```

The watcher is optional: development is configured with `compile: true`, so shakapacker compiles packs on demand. Running it just avoids paying for that on the first request after a change.

There is no `webpack-dev-server`, and so no hot reload — a rebuild needs a browser refresh.

### Tests and linters

```sh
bundle exec rspec     # Ruby
npm test              # JavaScript, vitest
bundle exec rubocop   # Ruby lint
npm run lint          # JavaScript lint, eslint
```

All four run in CI, and `Tests`, `JS Tests`, `Rubocop` and `Lint` are required before a pull request can merge.

### Environment variables

| Variable | Used for |
|---|---|
| `DATABASE_HOST` | Defaults to `localhost`. Set to `127.0.0.1` to reach MySQL over TCP, such as a container. |
| `DATABASE_PASSWORD` | Database password. Empty by default. |
| `RUN_TYPE` | `web` migrates at boot; `worker` is used by the Sidekiq process. |
| `REDIS_URL` | Sidekiq connection. |
| `ADMIN_USER`, `ADMIN_PASSWORD` | HTTP basic auth on `/admin`. Only enforced in production and test. |
| `BUGSNAG_API_KEY` | Error reporting. Absent in development, which logs a harmless notice. |

## Credits

"Bell, Counter, A.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org
