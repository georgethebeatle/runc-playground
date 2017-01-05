#!/bin/bash

set -e -x

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

add-apt-repository ppa:neovim-ppa/unstable
apt-get -y update
apt-get -y clean

apt-get install -y curl git gcc make jq cgroup-lite silversearcher-ag neovim python-dev python-pip python3-dev python3-pip

wget -qO- https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz | tar -C /usr/local -xzf -

# set up bash-it
if [ ! -d ~/.bash_it ]; then
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  ~/.bash_it/install.sh --silent
fi

#Set up git aliases
cat > $HOME/.bash_it/custom/git_config.bash <<EOF
#!/usr/bin/env bash

git config --global core.editor vim
git config --global core.pager "less -FXRS -x2"

git config --global alias.co checkout
git config --global alias.st status
git config --global alias.b branch
git config --global alias.plog "log --graph --abbrev-commit --decorate --date=relative --format=format:\'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
EOF

#Set up $GOPATH and add go executables to $PATH
cat > $HOME/.bash_it/custom/go_env.bash <<EOF
#!/usr/bin/env bash

export GOPATH=/root/go
export PATH=/root/go/bin:/usr/local/go/bin:$PATH

alias vim=nvim
EOF

source $HOME/.bash_it/custom/go_env.bash

# Set up vim for golang development
git clone https://github.com/luan/vimfiles.git $HOME/.vim
curl vimfiles.luan.sh/install | bash
pip3 install neovim

RUNC_PATH=$GOPATH/src/github.com/opencontainers
mkdir -p $RUNC_PATH
git clone https://github.com/opencontainers/runc $RUNC_PATH/runc

pushd $RUNC_PATH/runc
  GOPATH=$PWD/Godeps/_workspace:$GOPATH go build -o runc .
  cp runc /usr/local/bin/runc
popd

# Set up tmux
wget -O $HOME/.tmux.conf https://raw.githubusercontent.com/luan/dotfiles/master/tmux.conf

# install docker
wget -qO- https://get.docker.com/ | sh

echo Done
