#!/bin/bash

set -e -x

apt-get -y update
apt-get -y clean

apt-get install -y curl git gcc make python-dev vim-nox jq cgroup-lite silversearcher-ag

wget -qO- https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz | tar -C /usr/local -xzf -

# Set up vim for golang development
git clone https://github.com/luan/vimfiles.git $HOME/.vim
$HOME/.vim/install --non-interactive

# set up bash-it
if [ ! -d ~/.bash_it ]; then
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  $HOME/.bash_it/install.sh --none
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
EOF

source $HOME/.bash_it/custom/go_env.bash

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
apt-get -y install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

mkdir -p /etc/apt/sources.list.d
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
apt-get update

apt-cache policy docker-engine
apt-get install -y linux-image-extra-$(uname -r) docker-engine
service docker start

echo Done
