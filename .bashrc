export PATH="$PATH:/usr/loca/bin"
export EDITOR=/usr/bin/vim

RED="\[\e[0;31m\]"
GREEN="\[\e[0;32m\]"
YELLOW="\[\e[0;33m\]"
BLUE="\[\e[0;36m\]"
WHITE="\[\e[0;37m\]"
RESET="\[\e[0m\]"

prompt_user() {
	user=$(whoami)

	if [ $user == "root" ]; then
		echo "$RED$user"
	else
		echo "$GREEN$user"
	fi
}

prompt_command() {
	local PUSER=$(prompt_user)
	local PHOST="$GREEN\h"
	local PPATH="$BLUE\W$RESET"

	export PS1="[$PUSER$WHITE@$PHOST $PPATH]\\$ "
}

PROMPT_COMMAND=prompt_command

# FIXME: make it more pretty
ID_RSA="/home/spectre/.ssh/id_rsa"
alias use_comp_ssh_key='cp "$ID_RSA"_comp "$ID_RSA" && cp "$ID_RSA".pub_comp "$ID_RSA".pub'
alias use_nout_ssh_key='cp "$ID_RSA"_nout "$ID_RSA" && cp "$ID_RSA".pub_nout "$ID_RSA".pub'

alias info='info --vi-keys'
alias vi='vim'

# smart unpack (http://muhas.ru/?p=55)
unpack() {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1 ;;
			*.tar.gz)    tar xzf $1 ;;
			*.bz2)       bunzip2 $1 ;;
			*.rar)       unrar x $1 ;;
			*.gz)        gunzip $1 ;;
			*.tar)       tar xf $1 ;;
			*.tbz2)      tar xjf $1 ;;
			*.tgz)       tar xzf $1 ;;
			*.zip)       unzip $1 ;;
			*.Z)         uncompress $1 ;;
			*.7z)        7z x $1 ;;
			*)           echo "Cannot unpack '$1'..." ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

TMP_SSH_AGENT_PATH=/tmp/zsh-ssh-agent.out
update-ssh-agent-info() {
	if [ -f ${TMP_SSH_AGENT_PATH} ] ; then
		source ${TMP_SSH_AGENT_PATH} > /dev/null
	fi
}

run-ssh-agent() {
	ssh-agent > ${TMP_SSH_AGENT_PATH}
	update-ssh-agent-info
}

update-ssh-agent-info
