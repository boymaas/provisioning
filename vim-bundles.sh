# vim +BundleInstall +qall

cd $HOME/.vim/bundle/Command-T/ruby/command-t/
rbenv local system
ruby extconf.rb make
make
rbenv local 2.0.0-p247
