install() {
  apt-get install -y -qq $*
}

# build requirements for bitcoind
install_build_essentials() {
  install build-essential \
          libtool autotools-dev autoconf \
          libssl-dev \
          libboost-all-dev \
          pkg-config 
}

environment_setup() {
  apt-get update
  install vim htop whois git make
  install python-software-properties

  install_build_essentials
}

export -f install
export -f environment_setup
