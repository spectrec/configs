INSTALL="/usr/bin/install"

install_all: vim git ssh xinit tmux awesome redshift

vim: .vimrc
	$(INSTALL) -t ~/ .vimrc

tmux: .tmux.conf
	$(INSTALL) -t ~/ .tmux.conf

git: .gitconfig
	$(INSTALL) -t ~/ .gitconfig

ssh: .ssh/config
	$(INSTALL) -t ~/.ssh/ .ssh/config

xinit: .xinitrc
	$(INSTALL) -t ~/ .xinitrc

awesome: rc.lua
	mkdir -p ~/.config/awesome/
	$(INSTALL) -t ~/.config/awesome/ rc.lua

redshift: redshift.conf
	$(INSTALL) -t ~/.config/ redshift.conf
