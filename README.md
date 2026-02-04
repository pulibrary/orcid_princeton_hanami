# OrcidPrinceton

This application leverages ORCID services and ORCID iDs for researchers in the Princeton community.

This is an updated version of ORCID Princeton written on the [Hanami platform](https://hanamirb.org).

The original code for the rails application is located at [https://github.com/pulibrary/orcid_princeton](https://github.com/pulibrary/orcid_princeton)

[![CircleCI](https://circleci.com/gh/pulibrary/orcid_princeton_hanami/tree/main.svg?style=svg)](https://circleci.com/gh/pulibrary/orcid_princeton_hanamo/tree/main)

[![Coverage Status](https://coveralls.io/repos/github/pulibrary/orcid_princeton_hanami/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/orcid_princeton_hanami?branch=main)

## Devbox (Quick Start)

We ship a Devbox environment to standardize Ruby, Postgres, and build dependencies.
Devbox runs a **local Postgres server** backed by a unix socket at `./.postgres` (and `/tmp`).
Database URLs are derived from repo-local defaults (so nothing user-specific needs to be committed).

### 1) enter the reproducible shell (first time only: install deps)

```sh
devbox update
devbox run setup
```

### 2) initialize/start Postgres and prepare dev & test DBs

```sh
devbox run db-prepare
```

### 3) Run the Hanami app local/lan setup)

```sh
devbox run web
```

Helpful commands:

```sh
devbox run postgres-status
devbox run postgres-log
devbox run db-migrate
```

  > Binstubs are written to `.binstubs/` and added to PATH. Bundled gems go to `.bundle/`. Both are `.gitignored`.
  > Notes: Postgres data lives in `./.postgres/data` and logs in `./.postgres/postgres.log`

## Dependencies

* Ruby: 3.4.2
* nodejs: 22.14.0
* yarn: 1.22.22
* Lando: 3.6.2

If not using Devbox: you’ll need Ruby (with OpenSSL/Readline), Postgres client libs/headers, and build tools installed locally.

## Updating the banner

Update the the environment variables either via [Princeton Ansible](https://github.com/pulibrary/princeton_ansible/blob/main/group_vars/orcid/production.yml#L25-L26) for long term changes or by modifying the `~deploy/app_configs/orcid_princeton` on each server and restarting passenger/nginx (`sudo service nginx restart`) on each server for short term changes.

## Creating an ORCID sandbox account

1. A Mailinator account is required for you to be able to verify your ORCID account. "Setup" your Mailinator your email:
     1. visit <https://www.mailinator.com/v4/public/inboxes.jsp>
     1. put a fake email address (e.g., myname) into the search box at the top of the page.
        * your email wil include `@mailinator.com` (e.g. `myname@mailinator.com`) even though you do not need to put `@mailinator.com` in the search box
     1. Click go and you will be taken to the "inbox" for that email.
1. Use the mailinator email address (e.g. `myname@mailinator.com`) to register an account at <https://sandbox.orcid.org/register>
1. Record your login and password in a password manager so you can find them again.
1. Now in mailinator respond to the verification email.
   * If you do not see your email make sure the search box has your email. You do not need to include `mailinator.com`
   * Click the verify button in the email
1. Your account should now be verified in the OCRID Sandbox

---

## Converting the rails database

Prior to utilizing the rails database for the hanami application you need convert the tokens in the [rails application](https://github.com/pulibrary/orcid_princeton/blob/main/lib/tasks/tokens.rake) and to update the migrations table.

### Development

In development to convert your rails database to be able to run with Hanami you need to run (the commands below assume the port returned in lando info is 51512 )

```bash
cd orcid_princeton
bundle exec rake tokens:openssl
cd orcid_princeton_hanami
lando info
psql --host 127.0.0.1 --username=postgres --port 51512 -d development_db < config/db/update_rails_migration.sql
```

### Staging and Production

Before deploying the hanami application for the first time or in a rails release of the application on the server run the following to update the the encrypted tokens.

```bash
cd /opt/orcid_princeton/current
bundle exec rake tokens:openssl
```

In staging and production the database information is stored in environment variables. To update the database you should run

```bash
cd /opt/orcid_princeton/current
echo $APP_DB_PASSWORD
psql --host $APP_DB_HOST --username=$APP_DB_USERNAME -d $APP_DB < config/db/update_rails_migration.sql
```

---

## Local development

### Setup

1. Check out code and `cd`
1. Install tool dependencies; If you've worked on other PUL projects they will already be installed.
    1. [Lando](https://docs.lando.dev/getting-started/installation.html)
    1. [asdf](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)
    1. postgres (`brew install postgresql`: Postgres runs inside a Docker container, managed by Lando, but the `pg` gem still needs a local Postgres library to install successfully.)
1. Install asdf dependencies with asdf
    1. `asdf plugin add ruby`
    1. `asdf plugin add node`
    1. `asdf plugin add yarn`
    1. `asdf install`
    1. ... but because asdf is not a dependency manager, if there are errors, you may need to install other dependencies. For example: `brew install gpg`
1. Install [devbox](bin/first-time-setup)
    1. `devbox shell`
    1. `devbox run setup`
1. Or, if you are using `ruby-install` and `chruby` (instead of `asdf`):
    1. `ruby-install 3.2.0 -- --with-openssl-dir=$(brew --prefix openssl@1.1)`
    2. close the terminal window and open a new terminal
    3. `chruby 3.2.0`
    4. `ruby --version`
1. Install language-specific dependencies
    1. `bundle install`
    2. `yarn install`

### Starting / stopping services

We use lando to run services required for both test and development environments.

Start and initialize database services with:

```text
lando start
hanami db create
hanami db migrate
```

To stop database services:

`lando stop`

### Running tests

1. Fast: `bundle exec rspec spec`
2. Run in browser: `RUN_IN_BROWSER=true bundle exec rspec spec`

### Starting the development server

The application can be run in development mode by running `bin/dev` from the hanami application directory.
Hanami runs by default at the port 2300, but we have made this application run at the default rails port 3000 [localhost](http://localhost:3000)

1. `bin/dev`
1. Access application at [http://localhost:3000/](http://localhost:3000/)

### ORCID Environment variables

You need to have the following variables in your environment to connect with the ORCID sandbox. Actual values are in lastpass under "ORCID Local API key".
export ORCID_CLIENT_ID="xxx"
export ORCID_CLIENT_SECRET="xxx"

### environment files

 With Hanami environment variables for development and test are put in `.env` & `.env.test` or `.env.dev` files. You can keep secret information in `.env.dev.local` if you like or set them up as environment variables/

## Release and deployment

RDSS uses the same [release and deployment process](https://github.com/pulibrary/rdss-handbook/blob/main/release_process.md) for all projects.

## Monitoring

You can view the ORCID [Honeybadger Uptime check](https://app.honeybadger.io/projects/114910/sites/e8dbf0b6-00b3-4b71-afb2-5ce88138a9a6). Currently it checks every minute and will report downtime when two checks fail in a row (i.e. we should know within 2 minutes).

To be notified of downtime enable notifications in Honeybadger under: Settings + Alerts & Integrtions + email (Edit). Enable notifications for "Uptime Events" for "ORCID Production". Notice that email notifications settings are *per project*.

## ORCID Branding

In compliance with ORCID's [general brand guidance](https://info.orcid.org/brand-guidelines/#h-general-brand-guidance) around capitalization of the ORCID organization name and ORCID identifier information, we use the following written style to refer to ORCID and ORCID identifiers:

* **ORCID** - (noun) the ORCID organization; (adjective) part of a noun phrase that refers to things that are about ORCID, but not by the organization itself
  * Noun example: "ORCID is a global, not-for-profit organization."
  * Adjective example: "Click here to view your ORCID record"
* **ORCID identifer** or **ORCID iD** (abbreviation) - unique identifer offered by the ORCID organization
