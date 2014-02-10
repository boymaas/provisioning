#!/usr/bin/env bash

# using https://github.com/rkiel/vagrant-starter/tree/master/provision

postgresql_install() {
echo "Begin PostgreSQL"

echo "Installing Postgres 9.1"
apt-get install -y postgresql-9.1

echo "Creating role"
sudo -u postgres psql -c "create role crypto login createdb password 'crypto';"

echo "Updating template with UTF-8"
sudo -u postgres psql -c "update pg_database set datistemplate=false where datname='template1';"
sudo -u postgres psql -c "drop database Template1;"
sudo -u postgres psql -c "create database template1 with owner=postgres encoding='UTF-8' lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;"
sudo -u postgres psql -c "update pg_database set datistemplate=true where datname='template1';"

echo "Editing conf files to support network access"
# sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.1/main/postgresql.conf
# sed -i -e "s/127.0.0.1\/32/0.0.0.0\/0/"                               /etc/postgresql/9.1/main/pg_hba.conf

echo "Restarting"
service postgresql restart

echo "End PostgreSQL"
}

# TODO: record settings below and turn ssl to false,
#       otherwise problems with resque
postgresql_shmmax() {
# -- Dedicated server 8GB RAM
# shared_buffers = 1/3 .. 1/4 dedicated RAM
# effecttive_cache_size = 2/3 dedicated RAM

# maintenance_work_mem > higher than the most big table (if possible) 
#                       else 1/10 RAM 
#                       else max_connection * 1/4 * work_mem

# work_mem  = precious setting is based on slow query analyse 
#             (first setting about 100MB)

# --must be true
# max_connection * work_mem * 2 + shared_buffers 
#           + 1GB (O.S.) + 1GB (filesystem cache) <= RAM size
  page_size=`getconf PAGE_SIZE`
  phys_pages=`getconf _PHYS_PAGES`
  shmall=`expr $phys_pages / 2`
  shmmax=`expr $shmall \* $page_size`
  echo kernel.shmmax = $shmmax >>/etc/sysctl.conf
  echo kernel.shmall = $shmall >>/etc/sysctl.conf
  sysctl -p
}


postgresql_create_database_and_role() {
  # echo "Creating role and database"
  sudo -u postgres psql -c "create role $1 with login createdb superuser password '$1';"
  sudo -u postgres psql -c "create database $1;"
  sudo -u postgres psql -c "grant all on database $1 to $1;"
}

export -f postgresql_shmmax
export -f postgresql_install
export -f postgresql_create_database_and_role
