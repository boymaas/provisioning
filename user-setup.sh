
function user_create_with_password() {
  echo "Create user to run app under"
  pass=$(perl -e 'print crypt($ARGV[0], "password")' "random seed")
  useradd -m -p $pass $1 -s /bin/bash
}

function user_sudo_nopasswd() {
  echo "$1    ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers
}

function user_generate_ssh_keys() {
  echo "Generate ssh keys"
  # first generate to be sure they are there
  # and correct seggins
  sudo -u $1 -i <<EOS
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
EOS
}

user_install_github_keys () {
  cat provision/user-github-keys/id_rsa >/home/$1/.ssh/id_rsa
  cat provision/user-github-keys/id_rsa.pub >/home/$1/.ssh/id_rsa.pub
}

user_install_authorized_key() {
  auth_keys_file=/home/$1/.ssh/authorized_keys
  cat provision/user-deploy-keys/$2 >>$auth_keys_file
  chown $1 $auth_keys_file
  chmod 600 $auth_keys_file
}

# echo "Enabling crypto user ssh"
# echo 'crypto  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

function user_add_github_keys() {
  echo "Adding githubs key to known hosts, for easy deployment"
  sudo -u $1 -i <<EOS
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
EOS
}


function user_install_rbenv() {
echo "Install rbenv for this user so deploy can go"
  sudo -u $1 -i <<EOF
    git clone https://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="\$HOME/.rbenv/bin:\$PATH"' >> .profile
    echo 'eval "\$(rbenv init -)"' >> .profile

    git clone https://github.com/sstephenson/ruby-build.git .rbenv/plugins/ruby-build
EOF
}

function user_install_rbenv_ruby() {
echo "Install the local ruby version and rbenv sudo cuz we need it"
  sudo -u $1 -i <<EOF
    rbenv install 2.0.0-p247
    rbenv system 2.0.0-p247
    rbenv local 2.0.0-p247

    git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo

    gem install bundler
    rbenv rehash
EOF
}

user_create_and_setup() {
  user_create_with_password $1
  user_setup $1
}

function user_setup() {
  user_generate_ssh_keys $1
  user_add_github_keys $1
  user_install_rbenv $1
  user_install_rbenv_ruby $1
}

export -f user_setup
export -f user_create_and_setup
export -f user_install_github_keys

