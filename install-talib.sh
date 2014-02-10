
function install_talib() {
(
  cd vendor/
  tar xzf ta-lib.tgz
  cd ta-lib
  ./configure
  make
  make install
)

  ARCHFLAGS="-arch i386" 
  sudo -u vagrant -i <<EOF
    gem install talib_ruby -- \
      --with-talib-include=/usr/local/include/ta-lib/ \
      --with-talib-lib=/usr/local/lib
EOF

  ( cd vendor/ && rm -r ta-lib )

}

export -f install_talib
