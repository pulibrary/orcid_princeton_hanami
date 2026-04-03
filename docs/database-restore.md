# Restore Instructions

Note: these instructions were tested on a staging system in May, 2025. We hope to refine the process soon.

If you are dealing with a database failure of some kind and need to restore a database from a backup, take a deep breath and follow these instructions:

1. Retrieve the Database Backup
   1. get on the server
      ```
      ssh pulsys@lib-postgres-prod1.princeton.edu
      sudo su - postgres
      source .env.restic
      ```
   1. Find the restic hash by looking through the snapshots for the orcid_prod one
      ```
      restic -r $RESTIC_ARCHIVE_REPOSITORY -p /var/lib/postgresql/.restic.pwd snapshots |grep orcid_prod
      ```
   1. Utilize the hash to restore the backup **You must replace the <hash> in the command below**
      ```
      restic -r $RESTIC_ARCHIVE_REPOSITORY -p /var/lib/postgresql/.restic.pwd restore <hash> -t /tmp
      ```
      Puts the backup under /tmp/postgresql
   1. Veryfy that the back up was created
      ```
      ls -ltr /tmp/postgresql/orcid_prod*
      ```
1. Open a separate shell on your local machine
1. From your local machine run the following scp to transfer the backup to your local machine.
    ```bash
    scp pulsys@lib-postgres-prod1.princeton.edu:/tmp/postgresql/orcid_prod.sql.gz ./orcid_production.sql.gz
    ```
1. Use scp to transfer the backup from your local machine to the web server.
    For Production
    ```bash
    scp orcid_production.sql.gz pulsys@orcid-prod1.princeton.edu:/tmp
    ```

    For Staging
    ```bash
    scp orcid_production.sql.gz pulsys@orcid-staging1.princeton.edu:/tmp
    ```

1. unzip the backup files.
    For Production
    ```bash
    ssh pulsys@orcid-prod1.princeton.edu
    cd /tmp
    gzip -d orcid_production.sql.gz
    ```

    For staging
    ```bash
    ssh pulsys@orcid-staging1.princeton.edu
    cd /tmp
    gzip -d orcid_production.sql.gz
    ```
1. View the backup `.sql` file to confirm that it references the correct database name.
   **Note** if your are restoring production on a lower server you will need to search and replace the file
   * edit the file utilizing `:%s/orcid_prod/orcid_staging/g` command to replace the name
   
1. Stop the Nginx service on all web servers to close the connections and allow the database to be recreated.

   For Production
   ```
   ssh pulsys@orcid-prod1.princeton.edu
   sudo systemctl stop nginx
   exit
   ssh pulsys@orcid-prod2.princeton.edu
   sudo systemctl stop nginx
   exit
   ```

   For Staging:
   ```
   ssh pulsys@orcid-staging1.princeton.edu
   sudo systemctl stop nginx
   exit
   ssh pulsys@orcid-staging1.princeton.edu
   sudo systemctl stop nginx
   exit
   ```
   *If you are restoring on your local system CTRL-C the rails server*
1. On the database server  wait until the connections have closed. You can check for active connections with
   For Production
   ```
   ssh pulsys@lib-postgres-prod1.princeton.edu
   ps aux | grep postgres | grep <database-name>
   ```
   For Production
   ```
   ssh pulsys@lib-postgres-prod1.princeton.edu
   ps aux | grep postgres | grep <database-name>
   ```
1. The restore process is designed to drop the original database and recreate it before restoring the tables from the backup, but right now those tasks fail, so we need to do them manually.
    1. On the database server, as the postgres user, manually drop the existing/old/corrupted database:
       For Production
         ```bash
         sudo su - postgres
         dropdb orcid_prod
         ```
       For Staging
         ```bash
         sudo su - postgres
         dropdb orcid_staging
         ```
    1. On the database server, as the postgres user, manually recreate an empty database to restore to:
       For Production
        ```bash
         createdb -O orcid_staging orcid_staging
         ```
       For Staging
         ```bash
         createdb -O orcid_staging orcid_staging
         ```
1. On the web server, run the command to restore the tables from the backup file - the command passes the correct database owner: **Note** The password will be on the sccreen from the cat command
     For Production
     ```bash
     ssh deploy@orcid-staging1.princeton.edu
     sudo cat ~deploy/app_configs/orcid_princeton |grep APP_DB_PASSWORD
     psql -h lib-postgres-prod1.princeton.edu -U orcid_production -d orcid_prod -f /tmp/orcid_production.sql
     ```

     For Staging
     ```bash
     ssh deploy@orcid-staging1.princeton.edu
     sudo cat ~deploy/app_configs/orcid_princeton |grep APP_DB_PASSWORD
     psql -h lib-postgres-staging1.princeton.edu -U orcid_staging -d orcid_staging -f /tmp/orcid_production.sql
     ```

1. On the database server, log into postgres (as the postgres user, do `psql`). Confirm that the database exists and has tables that are owned by the correct user.
     1. check the tables owner For Production:
        ```
        ssh pulsys@lib-postgres-prod1.princeton.edu
        sudo su - postgres
        psql
        ```
        Inside postgres verify who owns the tables.  it needs to be orcid_production
        ```bash
        \c orcid_prod
        \dt
        \q
        ```

        For Staging:
        ```
        ssh pulsys@lib-postgres-staging1.princeton.edu
        sudo su - postgres
        psql
        ```

        Inside postgres verify who owns the tables.  it needs to be orcid_staging
        ```bash
        \c orcid_staging
        \dt
        \q
        ```

    1. If the tables are owned by the `postgres` user fix table ownership by running this as the postgres user:
       ```bash
       for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" orcid_prod`; do psql -c "alter table public.\"$tbl\" owner to orcid_production" -d orcid_prod -U postgres
       done
       ```
     
1. Restart the Nginx services on the web servers.
   For production
   ```
   ssh pulsys@orcid-prod1.princeton.edu
   sudo systemctl start nginx
   exit
   ssh pulsys@orcid-prod2.princeton.edu
   sudo systemctl start nginx
   exit
   ```

   For Staging
   ```
   ssh pulsys@orcid-staging1.princeton.edu
   sudo systemctl start nginx
   exit
   ssh pulsys@orcid-staging2.princeton.edu
   sudo systemctl start nginx
   exit
   ```

1. Log into the service and verify the data was loaded successfully.
   if you are a sysadmin check the report

    For production:
    https://orcid.princeton.edu/admin/orcid_report

    For staging:
    https://orcid-staging.princeton.edu/admin/orcid_report

1. Do whatever else is appropriate to end the incident, then take another deep breath.
