nginx_install() {
  echo "Installing Nginx"
  apt-get install -y nginx >/dev/null 2>&1
}


nginx_place_config() {
  rm -f /etc/nginx/sites-enabled/default
  cp $1 /etc/nginx/sites-enabled/$(basename $1)
  service nginx start
}
