# OrcidPrinceton

This is an updated version of ORCID Princeton written on the Hanami platform.

## Converting the rails database

### Development
In development to convert your rails database to be able to run with Hanami you need to run (the commands below assume the port returned in lando info is 51512 )
```
lando info
psql --host 127.0.0.1 --username=postgres --port 51512 -d development_db < config/db/update_rails_migration.sql
```

### Staging and Production 
This is untested, but I believe you should run
```
cd /opt/orcid_princeton_current
echo $APP_DB_PASSWORD
psql --host $APP_DB_HOST --username=$APP_DB_USERNAME -d $APP_DB < config/db/update_rails_migration.sql
```