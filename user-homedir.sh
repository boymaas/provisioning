user_homedir_dotfiles() {
  sudo -u $1 -i <<EOF
    # install home dir
    git clone https://github.com/boymaas/dotfiles.git
    mv dotfiles/.git .
    rm -r dotfiles
    git checkout master .
EOF
}

user_homedir_vim() {
  # we need a vim with ruby support build in to compile against
  # command-T
  install vim-nox

  sudo -u $1 -i <<EOF
    if [ ! -L .vimrc ]; then
      # install vim config files
      git clone https://github.com/boymaas/vimfiles.git 
      mv vimfiles .vim 
      ln -s .vim/vimrc .vimrc

      cd .vim
      git submodule init
      git submodule update
    fi
EOF

  echo Perform bundle install and build command-t 
  echo USE SYSTEM RUBY TO BUILD COMMAND-T

  echo vim +BundleInstall +qall 

  echo

  echo    cd .vim/bundle/Command-t/ruby/command-t/ 
  echo    rbenv local system
  echo    ruby extconf.rb make
  echo    make
  echo    rbenv local 2.0.0-p247

}

user_homedir_tmux() {
  install cmake

  sudo -u $1 -i <<EOF
    git clone https://github.com/tony/tmux-config.git ~/.tmux-tony
    ln -s ~/.tmux-tony/.tmux.conf ~/.tmux.conf
    cd ~/.tmux-tony
    git submodule init
    git submodule update
    cd ~/.tmux-tony/vendor/tmux-mem-cpu-load
    cmake .
    make
    sudo make install
    cd ~
EOF
}

user_homedir_all() {
  user_homedir_dotfiles $1
  user_homedir_vim $1
  user_homedir_tmux $1
}

export -f user_homedir_tmux
export -f user_homedir_vim
export -f user_homedir_dotfiles

export -f user_homedir_all
