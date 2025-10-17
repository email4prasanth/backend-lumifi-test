- once EC2 is launched
```sh
mkdir ~/keys
nano ~/keys/DevOpsKey.pem
sudo chown ubuntu:ubuntu ~/keys/DevOpsKey.pem
chmod 600 ~/keys/DevOpsKey.pem
ssh -i ~/keys/DevOpsKey.pem ubuntu@<private_ip>
sudo apt update && sudo apt upgrade -y
sudo apt install postgresql-client -y
psql --version
# check pvt rds connectivity
nc -vz prod-db-private.cxkiky6us81t.us-east-1.rds.amazonaws.com 5432
psql -h prod-db-private.cxkiky6us81t.us-east-1.rds.amazonaws.com   -p 5432   -U dbadmin   -d prod_lumifi_private   -W
Password: Fji0rR30mb-MOAn^
\dt public.*
\l
\c prod_lumifi_private
\dt
\q
```
# check the public rds connection
```sh
nc -vz dev-lumifi-db.cxkiky6us81t.us-east-1.rds.amazonaws.com 5432
psql \
  -h dev-lumifi-db.cxkiky6us81t.us-east-1.rds.amazonaws.com \
  -p 5432 \
  -U dbadmin \
  -d dev_lumifi \
  -W
x6mTPvo_FH_y2Trw
# List all schemas, all tables in the current database, View table data

\dn
\dt public.*
\dt
SELECT * FROM public.employees LIMIT 10;
exit
```

- Step 1 — Verify connectivity

0. Step 0 - Intial setup for ubuntu 22.04
```sh
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install postgresql-client-16
psql --version && pg_dump --version && pg_restore --version
```
- Set up logical migration bash script in VM
```sh
sudo nano postgres_migration.sh
sudo chmod +x postgres_migration.sh # Make it executable
ls -al
./postgres_migration.sh
```
- List all schemas, all tables in the current database, View table data
```sh
\dn
\dt
SELECT * FROM public.employees LIMIT 10;
exit
```
- Check the reflections
```sh
nc -vz prod-db-private.cxkiky6us81t.us-east-1.rds.amazonaws.com 5432
psql   -h prod-db-private.cxkiky6us81t.us-east-1.rds.amazonaws.com   -p 5432   -U dbadmin   -d prod_lumifi_private   -W
Password: 
\l
\dt
SELECT * FROM public.employees LIMIT 10;
\q
```