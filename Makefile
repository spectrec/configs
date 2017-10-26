INSTALL="/usr/bin/install"

install_all: vim git ssh xinit tmux awesome

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
	$(INSTALL) -t ~/.config/awesome/ rc.lua
