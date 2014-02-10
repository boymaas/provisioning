# now add user and setup upstart
useradd -b /home/bitcoind -d /home/bitcoind -m -s /bin/bash bitcoind

install_bitcoind_daemon () {
  # ppa:source for install bitcoin deamon
  add-apt-repository -y ppa:bitcoin/bitcoin
  apt-get -qq update

  install bitcoind
}

install_bitcoind_testnet () {
  sudo -u bitcoind -i <<EOF
    git clone https://github.com/boymaas/bitcoin-testnet-box.git
    cd bitcoin-testnet-box
EOF
}

build_bitcoind_daemon() {
  echo "Building bitcoind daemon"

  install_build_essentials

  # These are specific to this version of bitcoin
  install libdb4.8-dev
  install libdb4.8++-dev
  # executing commands in subshell as user bitcoind
  # effectively changing PWD back to original when fininshed
  sudo -u bitcoind -i <<EOF
    if [ ! -d build ]; then
      git clone https://github.com/bitcoin/bitcoin.git build
      cd build
      git checkout 0.8.6
      ./autogen.sh
      ./configure
      make
      cd ..
    fi

    mkdir -p bin
    cp build/src/bitcoind bin/
EOF
}

# [ -f /home/bitcoind/bin/bitcoind ] || build_bitcoind_daemon
install_bitcoind_daemon
install_bitcoind_testnet

# now install bitcoin config
install_bitcoin_conf() {
  conf_file=$1
  cat provision/bitcoind/bitcoin.conf | \
    sed -e "s/##rpc_password##/$BITCOIND_RPC_PASSWORD/" | \
    sed -e "s/##rpc_user##/$BITCOIND_RPC_USER/" \
    >$conf_file

  chown bitcoind.bitcoind $conf_file
  chmod 644 $conf_file

}

sudo -u bitcoind mkdir -p /home/bitcoind/.bitcoin/
install_bitcoin_conf /home/bitcoind/.bitcoin/bitcoin.conf

cp provision/upstart/bitcoind.conf /etc/init/

# start the bitcoin deamon after forcing a config reload
# by sending a HUP

# We don't start the bitcoind since it loads a lot of resources
# in developent. This will be started up
# in production

echo **NOT STARTING DEAMON IN DEVELOPMENT MODE, STARTING TESTNET**
# kill -HUP 1 
# start bitcoind

sudo -u bitcoind -i <<EOF
  cd bitcoin-testnet-box
  make start
EOF
