#!/bin/bash

set -e -x

# Use us.archive.ubuntu.com instead of EC2 mirrors, which are broken
sed -i -e 's/http.*\.archive\.ubuntu\.com/http:\/\/us.archive.ubuntu.com/' /etc/apt/sources.list

rm -rf /etc/apt/sources.list.d/multiverse-trusty*



apt-get -y update
apt-get -y clean

apt-get install -y curl git gcc python-dev vim-nox jq cgroup-lite

wget -qO- https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz | tar -C /usr/local -xzf -

#Set up $GOPATH and add go executables to $PATH
cat > /etc/profile.d/go_env.sh <<EOF
export GOPATH=/root/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
EOF
chmod +x /etc/profile.d/go_env.sh

source /etc/profile.d/go_env.sh

mkdir -p $GOPATH/src/github.com/opencontainers/
pushd $GOPATH/src/github.com/opencontainers/
git clone https://github.com/opencontainers/runc
pushd runc

GOPATH=$PWD/Godeps/_workspace:$GOPATH go build -o runc .
cp runc /usr/local/bin/runc

export UCF_FORCE_CONFFNEW=YES
export DEBIAN_FRONTEND=noninteractive


# Set up tmux
wget -O /root/.tmux.conf https://raw.githubusercontent.com/luan/dotfiles/master/tmux.conf

# set up bash-it
if [ ! -d ~/.bash_it ]; then
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  $HOME/.bash_it/install.sh --none
fi

# install docker
apt-get update && apt-get -y install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

mkdir -p /etc/apt/sources.list.d
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
apt-get update

apt-cache policy docker-engine
apt-get install -y linux-image-extra-$(uname -r) docker-engine
service docker start

# Set up vim for golang development
curl vimfiles.luan.sh/install | bash

